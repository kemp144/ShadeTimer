import SwiftUI
import ShadeTimerCore

struct MenuBarLabelView: View {
    @ObservedObject var controller: AppController

    var body: some View {
        if let countText = controller.menuBarCountText {
            Label(countText, systemImage: controller.menuBarSymbolName)
        } else {
            Image(systemName: controller.menuBarSymbolName)
        }
    }
}
