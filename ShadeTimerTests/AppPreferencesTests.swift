import XCTest
@testable import ShadeTimerCore

@MainActor
final class AppPreferencesTests: XCTestCase {
    func testPreferencesPersistAcrossInstances() {
        let suiteName = "com.robertengel.ShadeTimerTests.preferences"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let initial = AppPreferences(defaults: defaults)
        initial.targetDimOpacity = 0.61
        initial.fadeDuration = 4.2
        initial.dimAllDisplays = true
        initial.graduallyDimUntilTimerEnds = true
        initial.showRemainingTimerInMenuBar = true
        initial.sleepComputerWhenTimerEnds = true

        let restored = AppPreferences(defaults: defaults)
        XCTAssertEqual(restored.targetDimOpacity, 0.61, accuracy: 0.001)
        XCTAssertEqual(restored.fadeDuration, 4.2, accuracy: 0.001)
        XCTAssertTrue(restored.dimAllDisplays)
        XCTAssertTrue(restored.graduallyDimUntilTimerEnds)
        XCTAssertTrue(restored.showRemainingTimerInMenuBar)
        XCTAssertTrue(restored.sleepComputerWhenTimerEnds)
    }
}
