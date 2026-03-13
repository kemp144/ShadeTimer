import Combine
import Foundation

@MainActor
final class TimerManager: ObservableObject {
    @Published private(set) var remainingTime: TimeInterval?

    var onExpiration: (@MainActor () -> Void)?

    private let tickInterval: TimeInterval
    private let now: @Sendable () -> Date
    private var countdownTask: Task<Void, Never>?

    init(
        tickInterval: TimeInterval = 1.0,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.tickInterval = tickInterval
        self.now = now
    }

    var isRunning: Bool {
        remainingTime != nil
    }

    func start(duration: TimeInterval) {
        cancel()
        remainingTime = duration

        let deadline = now().addingTimeInterval(duration)
        countdownTask = Task { [weak self] in
            guard let self else { return }
            await self.runCountdown(until: deadline)
        }
    }

    func cancel() {
        countdownTask?.cancel()
        countdownTask = nil
        remainingTime = nil
    }

    private func runCountdown(until deadline: Date) async {
        let nanoseconds = UInt64(max(tickInterval, 0.05) * 1_000_000_000)

        while !Task.isCancelled {
            let remaining = max(0, deadline.timeIntervalSince(now()))
            remainingTime = remaining

            if remaining <= 0 {
                countdownTask = nil
                remainingTime = nil
                onExpiration?()
                return
            }

            do {
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                return
            }
        }
    }
}
