import Foundation
import IOKit
import IOKit.pwr_mgt

enum SleepManagerError: Error {
    case unavailable
    case failed(IOReturn)
}

final class SleepManager {
    func sleepSystem() throws {
        let port = IOPMFindPowerManagement(mach_port_t(0))
        guard port != 0 else {
            throw SleepManagerError.unavailable
        }

        let result = IOPMSleepSystem(port)
        IOServiceClose(port)

        guard result == kIOReturnSuccess else {
            throw SleepManagerError.failed(result)
        }
    }
}
