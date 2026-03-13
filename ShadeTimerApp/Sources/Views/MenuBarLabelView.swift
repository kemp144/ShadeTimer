import SwiftUI
import ShadeTimerCore

struct MenuBarLabelView: View {
    @ObservedObject var controller: AppController

    var body: some View {
        Image(systemName: controller.menuBarSymbolName)
    }
}
