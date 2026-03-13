import SwiftUI
import ShadeTimerCore

struct MenuBarContentView: View {
    @ObservedObject var controller: AppController
    @ObservedObject private var preferences: AppPreferences
    @State private var dimAllDisplaysValue = false
    @State private var gradualDimUntilTimerEndsValue = false
    @State private var customMinutesText = ""
    @State private var isShowingCustomTimerInput = false
    @FocusState private var isCustomMinutesFocused: Bool

    init(controller: AppController) {
        self.controller = controller
        _preferences = ObservedObject(wrappedValue: controller.preferences)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                statusCard
                timerCard
                controlCard
                moreSettingsCard
                footerRow
            }
            .padding(14)
        }
        .frame(width: 392, height: 620)
        .background(.regularMaterial)
        .onAppear {
            syncLocalState()
        }
        .onChange(of: isShowingCustomTimerInput) { value in
            guard value else { return }
            DispatchQueue.main.async {
                isCustomMinutesFocused = true
            }
        }
        .onReceive(preferences.$dimAllDisplays) { value in
            dimAllDisplaysValue = value
        }
        .onReceive(preferences.$graduallyDimUntilTimerEnds) { value in
            gradualDimUntilTimerEndsValue = value
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(controller.stateTitle)
                .font(.headline)

            Text(controller.stateSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let errorMessage = controller.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Timer")
                .font(.headline)

            Menu {
                ForEach(TimerPreset.allCases) { preset in
                    Button(menuTitle(for: preset)) {
                        controller.selectTimer(preset)
                        isShowingCustomTimerInput = false
                    }
                }

                Divider()

                Button("Custom Minutes") {
                    isShowingCustomTimerInput = true
                }
            } label: {
                HStack(spacing: 8) {
                    Label(currentTimeSelectionLabel, systemImage: "timer")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(.white.opacity(0.08))
                )
            }
            .menuStyle(.borderlessButton)

            if isShowingCustomTimerInput {
                HStack(spacing: 8) {
                    TextField("Minutes", text: $customMinutesText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 92)
                        .focused($isCustomMinutesFocused)
                        .onSubmit {
                            selectCustomTimer()
                        }

                    Text("min")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button("Use") {
                        selectCustomTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Hide") {
                        customMinutesText = ""
                        isShowingCustomTimerInput = false
                    }
                    .controlSize(.small)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var controlCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Button("Start Timer") {
                    controller.startSelectedTimer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!controller.canStartTimer)

                Button("Restore") {
                    controller.restore()
                }
                .disabled(!controller.isDimmed)

                Button("Cancel") {
                    controller.cancelTimer()
                }
                .disabled(!controller.isTimerActive)
            }

            Divider()

            Toggle("All Displays", isOn: $dimAllDisplaysValue)
                .onChange(of: dimAllDisplaysValue) { newValue in
                    controller.setDimAllDisplays(newValue)
                }

            Toggle("Gradually dim until timer ends", isOn: $gradualDimUntilTimerEndsValue)
                .onChange(of: gradualDimUntilTimerEndsValue) { newValue in
                    controller.setGraduallyDimUntilTimerEnds(newValue)
                }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var moreSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More Settings")
                .font(.headline)

            compactSlider(
                title: "Dim level",
                valueText: "\(Int(preferences.targetDimOpacity * 100))%",
                value: $preferences.targetDimOpacity,
                range: 0.15 ... 0.95
            )

            Text("The dim level after the timer finishes.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                compactSlider(
                    title: "Current dim level",
                    valueText: "\(Int(controller.currentDimOpacity * 100))%",
                    value: currentDimLevelBinding,
                    range: 0 ... 0.95
                )

                Text("Current dim level applies immediately while you drag it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            compactSlider(
                title: "Fade duration",
                valueText: String(format: "%.1fs", preferences.fadeDuration),
                value: $preferences.fadeDuration,
                range: 0.5 ... 10.0
            )

            Toggle("Show remaining timer in menu bar", isOn: $preferences.showRemainingTimerInMenuBar)

        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var footerRow: some View {
        HStack(spacing: 10) {
            Spacer()

            Button("Quit") {
                controller.quit()
            }
        }
        .font(.subheadline)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.quaternary.opacity(0.62))
    }

    private var currentTimeSelectionLabel: String {
        if let selectedPreset = controller.selectedPreset {
            return selectedPreset.buttonTitle
        }

        if let selectedCustomMinutes = controller.selectedCustomMinutes {
            return "\(selectedCustomMinutes) min"
        }

        return "Choose Time"
    }

    private func menuTitle(for preset: TimerPreset) -> String {
        preset.buttonTitle
    }

    private func compactSlider(
        title: String,
        valueText: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(valueText)
                    .foregroundStyle(.secondary)
            }

            Slider(value: value, in: range)
        }
    }

    private var currentDimLevelBinding: Binding<Double> {
        Binding(
            get: { controller.currentDimOpacity },
            set: { controller.setCurrentDimOpacity($0) }
        )
    }

    private func syncLocalState() {
        dimAllDisplaysValue = preferences.dimAllDisplays
        gradualDimUntilTimerEndsValue = preferences.graduallyDimUntilTimerEnds
    }

    private func selectCustomTimer() {
        let trimmedValue = customMinutesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let minutes = Int(trimmedValue) else {
            controller.selectCustomTimer(minutes: 0)
            return
        }

        controller.selectCustomTimer(minutes: minutes)

        if controller.errorMessage == nil {
            isShowingCustomTimerInput = false
            customMinutesText = ""
        }
    }
}
