import AppKit

struct DisplayDescriptor: Equatable {
    let id: CGDirectDisplayID
    let frame: CGRect
    let isPrimary: Bool

    static func currentDisplays(from screens: [NSScreen] = NSScreen.screens) -> [DisplayDescriptor] {
        screens.compactMap { screen in
            guard let id = screen.shadeTimerDisplayID else {
                return nil
            }

            return DisplayDescriptor(
                id: id,
                frame: screen.frame,
                isPrimary: CGDisplayIsMain(id) != 0
            )
        }
    }
}

enum DisplayTargetSelector {
    static func selectedDisplayIDs(from displays: [DisplayDescriptor], allDisplays: Bool) -> [CGDirectDisplayID] {
        guard allDisplays else {
            if let primary = displays.first(where: \.isPrimary) {
                return [primary.id]
            }

            return displays.first.map { [$0.id] } ?? []
        }

        return displays.map(\.id)
    }
}

extension NSScreen {
    var shadeTimerDisplayID: CGDirectDisplayID? {
        guard let value = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }

        return CGDirectDisplayID(value.uint32Value)
    }
}
