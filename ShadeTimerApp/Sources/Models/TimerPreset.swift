import Foundation

public enum TimerPreset: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10
    case fifteen = 15
    case thirty = 30
    case sixty = 60

    public var id: Int { rawValue }

    public var duration: TimeInterval {
        TimeInterval(rawValue * 60)
    }

    public var buttonTitle: String {
        AppLocalization.format("%ld min", rawValue)
    }

    public var compactTitle: String {
        AppLocalization.format("%ldm", rawValue)
    }
}
