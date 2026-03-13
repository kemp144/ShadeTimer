import SwiftUI
import ShadeTimerCore

@main
struct ShadeTimerApp: App {
    @StateObject private var controller = AppController()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(controller: controller)
        } label: {
            MenuBarLabelView(controller: controller)
        }
        .menuBarExtraStyle(.window)
    }
}
