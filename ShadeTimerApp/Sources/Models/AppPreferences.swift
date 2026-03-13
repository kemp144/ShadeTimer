import Combine
import Foundation

@MainActor
public final class AppPreferences: ObservableObject {
    enum Keys {
        static let targetDimOpacity = "targetDimOpacity"
        static let fadeDuration = "fadeDuration"
        static let dimAllDisplays = "dimAllDisplays"
        static let graduallyDimUntilTimerEnds = "graduallyDimUntilTimerEnds"
        static let showRemainingTimerInMenuBar = "showRemainingTimerInMenuBar"
        static let sleepComputerWhenTimerEnds = "sleepComputerWhenTimerEnds"
    }

    @Published public var targetDimOpacity: Double {
        didSet {
            let clamped = targetDimOpacity.clamped(to: 0.15 ... 0.95)
            guard clamped == targetDimOpacity else {
                targetDimOpacity = clamped
                return
            }

            defaults.set(clamped, forKey: Keys.targetDimOpacity)
        }
    }

    @Published public var fadeDuration: Double {
        didSet {
            let clamped = fadeDuration.clamped(to: 0.5 ... 10.0)
            guard clamped == fadeDuration else {
                fadeDuration = clamped
                return
            }

            defaults.set(clamped, forKey: Keys.fadeDuration)
        }
    }

    @Published public var dimAllDisplays: Bool {
        didSet { defaults.set(dimAllDisplays, forKey: Keys.dimAllDisplays) }
    }

    @Published public var graduallyDimUntilTimerEnds: Bool {
        didSet { defaults.set(graduallyDimUntilTimerEnds, forKey: Keys.graduallyDimUntilTimerEnds) }
    }

    @Published public var showRemainingTimerInMenuBar: Bool {
        didSet { defaults.set(showRemainingTimerInMenuBar, forKey: Keys.showRemainingTimerInMenuBar) }
    }

    @Published public var sleepComputerWhenTimerEnds: Bool {
        didSet { defaults.set(sleepComputerWhenTimerEnds, forKey: Keys.sleepComputerWhenTimerEnds) }
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        targetDimOpacity = defaults.object(forKey: Keys.targetDimOpacity) as? Double ?? 0.72
        fadeDuration = defaults.object(forKey: Keys.fadeDuration) as? Double ?? 2.5
        dimAllDisplays = defaults.object(forKey: Keys.dimAllDisplays) as? Bool ?? false
        graduallyDimUntilTimerEnds = defaults.object(forKey: Keys.graduallyDimUntilTimerEnds) as? Bool ?? false
        showRemainingTimerInMenuBar = defaults.object(forKey: Keys.showRemainingTimerInMenuBar) as? Bool ?? false
        sleepComputerWhenTimerEnds = defaults.object(forKey: Keys.sleepComputerWhenTimerEnds) as? Bool ?? false
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
