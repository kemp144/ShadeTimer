import AppKit

@MainActor
final class OverlayManager {
    private var overlays: [CGDirectDisplayID: OverlayPanel] = [:]
    private(set) var isDimmed = false
    private(set) var currentOpacity: Double = 0

    func dim(
        opacity: Double,
        fadeDuration: TimeInterval,
        allDisplays: Bool,
        timingFunctionName: CAMediaTimingFunctionName = .easeInEaseOut
    ) {
        let displays = DisplayDescriptor.currentDisplays()
        let targetIDs = Set(DisplayTargetSelector.selectedDisplayIDs(from: displays, allDisplays: allDisplays))

        for obsoleteID in overlays.keys where !targetIDs.contains(obsoleteID) {
            overlays[obsoleteID]?.close()
            overlays.removeValue(forKey: obsoleteID)
        }

        for display in displays where targetIDs.contains(display.id) {
            let isNewOverlay = overlays[display.id] == nil
            let overlay = overlays[display.id] ?? makeOverlay(for: display)
            overlay.setFrame(display.frame, display: true)
            if isNewOverlay {
                overlay.alphaValue = CGFloat(currentOpacity)
            }
            overlay.orderFrontRegardless()
            overlays[display.id] = overlay
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = fadeDuration
            context.timingFunction = CAMediaTimingFunction(name: timingFunctionName)

            for overlay in overlays.values {
                overlay.animator().alphaValue = CGFloat(opacity)
            }
        }

        currentOpacity = opacity
        isDimmed = !overlays.isEmpty
    }

    func refreshDisplays(
        allDisplays: Bool,
        fadeDuration: TimeInterval,
        timingFunctionName: CAMediaTimingFunctionName = .easeInEaseOut
    ) {
        guard isDimmed else { return }
        dim(
            opacity: currentOpacity,
            fadeDuration: fadeDuration,
            allDisplays: allDisplays,
            timingFunctionName: timingFunctionName
        )
    }

    func restore(fadeDuration: TimeInterval, completion: (@MainActor () -> Void)? = nil) {
        let panels = Array(overlays.values)
        guard !panels.isEmpty else {
            isDimmed = false
            currentOpacity = 0
            completion?()
            return
        }

        guard fadeDuration > 0 else {
            panels.forEach { $0.close() }
            overlays.removeAll()
            isDimmed = false
            currentOpacity = 0
            completion?()
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = fadeDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            for panel in panels {
                panel.animator().alphaValue = 0
            }
        } completionHandler: { [weak self] in
            MainActor.assumeIsolated {
                panels.forEach { $0.close() }
                self?.overlays.removeAll()
                self?.isDimmed = false
                self?.currentOpacity = 0
                completion?()
            }
        }
    }

    func tearDownImmediately() {
        overlays.values.forEach { overlay in
            overlay.alphaValue = 0
            overlay.close()
        }
        overlays.removeAll()
        isDimmed = false
        currentOpacity = 0
    }

    private func makeOverlay(for display: DisplayDescriptor) -> OverlayPanel {
        let panel = OverlayPanel(contentRect: display.frame)
        let view = NSView(frame: display.frame)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        panel.contentView = view
        panel.alphaValue = 0
        return panel
    }
}

private final class OverlayPanel: NSPanel {
    init(contentRect: CGRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue - 1)
        backgroundColor = .clear
        isOpaque = false
        ignoresMouseEvents = true
        hasShadow = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        animationBehavior = .none
        hidesOnDeactivate = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
