import XCTest
@testable import ShadeTimerCore

final class DisplayTargetSelectorTests: XCTestCase {
    func testPrimaryDisplayIsChosenWhenAllDisplaysIsDisabled() {
        let displays = [
            DisplayDescriptor(id: 1, frame: .zero, isPrimary: false),
            DisplayDescriptor(id: 2, frame: .zero, isPrimary: true),
            DisplayDescriptor(id: 3, frame: .zero, isPrimary: false)
        ]

        let selected = DisplayTargetSelector.selectedDisplayIDs(from: displays, allDisplays: false)
        XCTAssertEqual(selected, [2])
    }

    func testAllDisplaysAreChosenWhenEnabled() {
        let displays = [
            DisplayDescriptor(id: 11, frame: .zero, isPrimary: true),
            DisplayDescriptor(id: 12, frame: .zero, isPrimary: false)
        ]

        let selected = DisplayTargetSelector.selectedDisplayIDs(from: displays, allDisplays: true)
        XCTAssertEqual(selected, [11, 12])
    }
}
