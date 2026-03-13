import XCTest
@testable import ShadeTimerCore

@MainActor
final class TimerManagerTests: XCTestCase {
    func testTimerReplacementOnlyExpiresLatestTimer() async {
        let manager = TimerManager(tickInterval: 0.02)
        let expectation = expectation(description: "latest timer expires once")
        expectation.expectedFulfillmentCount = 1
        var expirations = 0

        manager.onExpiration = {
            expirations += 1
            expectation.fulfill()
        }

        manager.start(duration: 0.25)
        try? await Task.sleep(nanoseconds: 60_000_000)
        manager.start(duration: 0.08)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(expirations, 1)
        XCTAssertNil(manager.remainingTime)
    }

    func testCancelPreventsExpiration() async {
        let manager = TimerManager(tickInterval: 0.02)
        let expectation = expectation(description: "timer should not expire")
        expectation.isInverted = true

        manager.onExpiration = {
            expectation.fulfill()
        }

        manager.start(duration: 0.08)
        manager.cancel()

        await fulfillment(of: [expectation], timeout: 0.2)
        XCTAssertNil(manager.remainingTime)
    }
}
