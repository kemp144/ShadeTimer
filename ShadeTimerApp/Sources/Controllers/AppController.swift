import AppKit
import Combine
import Foundation

private enum ActiveTimerDimmingBehavior {
    case dimAtEnd
    case gradualUntilEnd
}

@MainActor
public final class AppController: ObservableObject {
    @Published public private(set) var state: AppState = .idle
    @Published public private(set) var remainingTime: TimeInterval?
    @Published public private(set) var selectedPreset: TimerPreset?
    @Published public private(set) var selectedCustomMinutes: Int?
    @Published public private(set) var currentDimOpacity: Double = 0
    @Published public private(set) var errorMessage: String?

    public let preferences: AppPreferences

    private let timerManager: TimerManager
    private let overlayManager: OverlayManager
    private let sleepManager: SleepManager
    private var activeTimerDuration: TimeInterval?
    private var activeTargetDimOpacity: Double?
    private var runningPreset: TimerPreset?
    private var runningCustomMinutes: Int?
    private var activeTimerDimmingBehavior: ActiveTimerDimmingBehavior = .dimAtEnd
    private var gradualSegmentStartOpacity: Double = 0
    private var gradualSegmentStartRemaining: TimeInterval?
    private var cancellables: Set<AnyCancellable> = []

    public init() {
        let preferences = AppPreferences()
        let timerManager = TimerManager()
        let overlayManager = OverlayManager()
        let sleepManager = SleepManager()
        self.preferences = preferences
        self.timerManager = timerManager
        self.overlayManager = overlayManager
        self.sleepManager = sleepManager
        self.currentDimOpacity = 0

        timerManager.onExpiration = { [weak self] in
            self?.handleTimerExpiration()
        }

        bindState()
        observeSystemNotifications()
    }

    init(
        preferences: AppPreferences,
        timerManager: TimerManager,
        overlayManager: OverlayManager,
        sleepManager: SleepManager = SleepManager()
    ) {
        self.preferences = preferences
        self.timerManager = timerManager
        self.overlayManager = overlayManager
        self.sleepManager = sleepManager
        self.currentDimOpacity = 0

        timerManager.onExpiration = { [weak self] in
            self?.handleTimerExpiration()
        }

        bindState()
        observeSystemNotifications()
    }

    public var menuBarSymbolName: String {
        switch state {
        case .idle:
            return "moon.stars"
        case .countingDown:
            return "timer"
        case .dimmed:
            return "circle.lefthalf.filled"
        }
    }

    public var stateTitle: String {
        switch state {
        case .idle:
            return AppLocalization.text("Ready to dim")
        case .countingDown:
            return AppLocalization.text("Timer running")
        case .dimmed:
            return AppLocalization.text("Screen dimmed")
        }
    }

    public var stateSubtitle: String {
        switch state {
        case .idle:
            return AppLocalization.text("Choose a time, start the timer, or drag Current dim level.")
        case .countingDown:
            let presetText: String
            if let runningPreset {
                presetText = runningPreset.buttonTitle
            } else if let runningCustomMinutes {
                presetText = AppLocalization.format("%ld min", runningCustomMinutes)
            } else {
                presetText = AppLocalization.text("Custom timer")
            }
            let remainingText = remainingTime.flatMap(Self.durationFormatter.string(from:)) ?? AppLocalization.text("Starting…")
            var modeSuffix = ""
            if activeTimerDimmingBehavior == .gradualUntilEnd {
                modeSuffix += AppLocalization.text(" • dimming gradually")
            }
            if preferences.sleepComputerWhenTimerEnds {
                modeSuffix += AppLocalization.text(" • sleep at end")
            }
            return AppLocalization.format("%1$@ • %2$@ remaining%3$@", presetText, remainingText, modeSuffix)
        case .dimmed:
            return AppLocalization.text("Use Restore when you want the screen back to normal.")
        }
    }

    public var isTimerActive: Bool {
        state == .countingDown
    }

    public var isDimmed: Bool {
        state == .dimmed
    }

    public var usesGradualDimmingForActiveTimer: Bool {
        state == .countingDown && activeTimerDimmingBehavior == .gradualUntilEnd
    }

    public var canStartTimer: Bool {
        selectedPreset != nil || selectedCustomMinutes != nil
    }

    public func selectTimer(_ preset: TimerPreset) {
        clearError()
        selectedPreset = preset
        selectedCustomMinutes = nil
    }

    public func selectCustomTimer(minutes: Int) {
        guard (1 ... 720).contains(minutes) else {
            errorMessage = AppLocalization.text("Enter a value between 1 and 720 minutes.")
            return
        }

        clearError()
        selectedPreset = nil
        selectedCustomMinutes = minutes
    }

    public func startSelectedTimer() {
        clearError()

        if let selectedPreset {
            startTimer(selectedPreset)
            return
        }

        if let selectedCustomMinutes {
            startTimer(duration: TimeInterval(selectedCustomMinutes * 60), preset: nil, customMinutes: selectedCustomMinutes)
            return
        }

        errorMessage = AppLocalization.text("Choose a time first.")
    }

    public func startTimer(_ preset: TimerPreset) {
        selectedPreset = preset
        selectedCustomMinutes = nil
        startTimer(duration: preset.duration, preset: preset, customMinutes: nil)
    }

    private func startTimer(duration: TimeInterval, preset: TimerPreset?, customMinutes: Int?) {
        clearError()
        if overlayManager.isDimmed {
            overlayManager.tearDownImmediately()
            currentDimOpacity = 0
        }

        timerManager.start(duration: duration)
        runningPreset = preset
        runningCustomMinutes = customMinutes
        remainingTime = duration
        activeTimerDuration = duration
        activeTargetDimOpacity = preferences.targetDimOpacity
        activeTimerDimmingBehavior = preferences.graduallyDimUntilTimerEnds ? .gradualUntilEnd : .dimAtEnd

        if activeTimerDimmingBehavior == .gradualUntilEnd {
            currentDimOpacity = 0
            beginGradualDimming(from: 0, remaining: duration)
        }

        state = .countingDown
    }

    public func cancelTimer() {
        timerManager.cancel()
        remainingTime = nil
        activeTimerDuration = nil
        activeTargetDimOpacity = nil
        runningPreset = nil
        runningCustomMinutes = nil

        if state == .countingDown, activeTimerDimmingBehavior == .gradualUntilEnd, overlayManager.isDimmed {
            overlayManager.restore(fadeDuration: preferences.fadeDuration)
        }

        activeTimerDimmingBehavior = .dimAtEnd
        gradualSegmentStartRemaining = nil
        gradualSegmentStartOpacity = 0
        currentDimOpacity = 0
        state = .idle
    }

    public func restore() {
        clearError()
        timerManager.cancel()
        remainingTime = nil
        activeTimerDuration = nil
        activeTargetDimOpacity = nil
        runningPreset = nil
        runningCustomMinutes = nil
        activeTimerDimmingBehavior = .dimAtEnd
        gradualSegmentStartRemaining = nil
        gradualSegmentStartOpacity = 0
        currentDimOpacity = 0
        overlayManager.restore(fadeDuration: preferences.fadeDuration) { [weak self] in
            self?.state = .idle
        }
        state = .idle
    }

    public func setDimAllDisplays(_ enabled: Bool) {
        preferences.dimAllDisplays = enabled
    }

    public func setGraduallyDimUntilTimerEnds(_ enabled: Bool) {
        preferences.graduallyDimUntilTimerEnds = enabled

        guard state == .countingDown else { return }

        let requestedBehavior: ActiveTimerDimmingBehavior = enabled ? .gradualUntilEnd : .dimAtEnd
        guard requestedBehavior != activeTimerDimmingBehavior else { return }

        activeTimerDimmingBehavior = requestedBehavior

        if requestedBehavior == .gradualUntilEnd {
            refreshGradualDimming()
        } else if overlayManager.isDimmed {
            overlayManager.restore(fadeDuration: preferences.fadeDuration)
            currentDimOpacity = 0
        }
    }

    public func setCurrentDimOpacity(_ opacity: Double) {
        clearError()

        let clampedOpacity = min(max(opacity, 0), 0.95)
        currentDimOpacity = clampedOpacity

        if usesGradualDimmingForActiveTimer {
            beginGradualDimming(from: clampedOpacity, remaining: max(remainingTime ?? 0, 0))
            return
        }

        if overlayManager.isDimmed {
            if clampedOpacity == 0 {
                timerManager.cancel()
                remainingTime = nil
                activeTimerDuration = nil
                activeTargetDimOpacity = nil
                runningPreset = nil
                runningCustomMinutes = nil
                activeTimerDimmingBehavior = .dimAtEnd
                gradualSegmentStartRemaining = nil
                gradualSegmentStartOpacity = 0
                overlayManager.restore(fadeDuration: 0)
                state = .idle
                return
            }

            applyCurrentDimOpacity(clampedOpacity, fadeDuration: 0)
            return
        }

        guard clampedOpacity > 0 else { return }

        if isTimerActive {
            timerManager.cancel()
            remainingTime = nil
            activeTimerDuration = nil
            activeTargetDimOpacity = nil
            runningPreset = nil
            runningCustomMinutes = nil
            activeTimerDimmingBehavior = .dimAtEnd
            gradualSegmentStartRemaining = nil
            gradualSegmentStartOpacity = 0
        }

        applyCurrentDimOpacity(clampedOpacity, fadeDuration: 0)
        state = .dimmed
    }

    public func dismissError() {
        clearError()
    }

    public func quit() {
        overlayManager.tearDownImmediately()
        timerManager.cancel()
        NSApplication.shared.terminate(nil)
    }

    private func bindState() {
        timerManager.$remainingTime
            .receive(on: RunLoop.main)
            .sink { [weak self] remaining in
                guard let self else { return }
                remainingTime = remaining
                if remaining != nil {
                    state = .countingDown
                }

                guard usesGradualDimmingForActiveTimer, let remaining else { return }
                currentDimOpacity = calculatedGradualOpacity(forRemaining: remaining)
            }
            .store(in: &cancellables)

        preferences.$dimAllDisplays
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshDimmingIfNeeded()
            }
            .store(in: &cancellables)
    }

    private func observeSystemNotifications() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshDimmingIfNeeded()
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshDimmingIfNeeded()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.overlayManager.tearDownImmediately()
                self?.timerManager.cancel()
            }
            .store(in: &cancellables)
    }

    private func handleTimerExpiration() {
        let targetDimOpacity = activeTargetDimOpacity ?? preferences.targetDimOpacity

        if activeTimerDimmingBehavior == .gradualUntilEnd {
            applyCurrentDimOpacity(targetDimOpacity, fadeDuration: 0, timingFunctionName: .linear)
        } else {
            applyCurrentDimOpacity(targetDimOpacity, fadeDuration: preferences.fadeDuration)
        }

        activeTimerDuration = nil
        runningPreset = nil
        runningCustomMinutes = nil
        activeTimerDimmingBehavior = .dimAtEnd
        gradualSegmentStartRemaining = nil
        gradualSegmentStartOpacity = targetDimOpacity

        guard preferences.sleepComputerWhenTimerEnds else {
            state = .dimmed
            return
        }

        do {
            try sleepManager.sleepSystem()
            overlayManager.tearDownImmediately()
            currentDimOpacity = 0
            state = .idle
        } catch {
            errorMessage = AppLocalization.text("Unable to put your Mac to sleep.")
            state = .dimmed
        }
    }

    private func refreshDimmingIfNeeded() {
        if usesGradualDimmingForActiveTimer {
            refreshGradualDimming()
            return
        }

        guard overlayManager.isDimmed else { return }

        applyCurrentDimOpacity(currentDimOpacity, fadeDuration: preferences.fadeDuration)
    }

    private func refreshGradualDimming() {
        let remaining = max(remainingTime ?? 0, 0)
        let currentOpacity = overlayManager.isDimmed ? currentDimOpacity : calculatedGradualOpacity(forRemaining: remaining)
        beginGradualDimming(from: currentOpacity, remaining: remaining)
    }

    private func calculatedGradualOpacity(forRemaining remaining: TimeInterval) -> Double {
        let targetOpacity = activeTargetDimOpacity ?? preferences.targetDimOpacity
        let referenceRemaining = gradualSegmentStartRemaining ?? activeTimerDuration ?? 0
        guard referenceRemaining > 0 else {
            return targetOpacity
        }

        let progress = 1 - min(max(remaining / referenceRemaining, 0), 1)
        let startOpacity = gradualSegmentStartRemaining == nil ? 0 : gradualSegmentStartOpacity
        return startOpacity + ((targetOpacity - startOpacity) * progress)
    }

    private func beginGradualDimming(from startOpacity: Double, remaining: TimeInterval) {
        let clampedStartOpacity = min(max(startOpacity, 0), 0.95)
        gradualSegmentStartOpacity = clampedStartOpacity
        gradualSegmentStartRemaining = remaining
        applyCurrentDimOpacity(clampedStartOpacity, fadeDuration: 0, timingFunctionName: .linear)

        guard remaining > 0 else { return }

        overlayManager.dim(
            opacity: activeTargetDimOpacity ?? preferences.targetDimOpacity,
            fadeDuration: remaining,
            allDisplays: preferences.dimAllDisplays,
            timingFunctionName: .linear
        )
    }

    private func applyCurrentDimOpacity(
        _ opacity: Double,
        fadeDuration: TimeInterval,
        timingFunctionName: CAMediaTimingFunctionName = .easeInEaseOut
    ) {
        overlayManager.dim(
            opacity: opacity,
            fadeDuration: fadeDuration,
            allDisplays: preferences.dimAllDisplays,
            timingFunctionName: timingFunctionName
        )
        currentDimOpacity = opacity
    }

    private func clearError() {
        errorMessage = nil
    }

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        return formatter
    }()

}
