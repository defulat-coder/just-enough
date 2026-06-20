import SwiftUI

@main
struct JustEnoughApp: App {
    @State private var store = JournalStore()

    var body: some Scene {
        WindowGroup {
            JournalAppView(store: store)
        }
    }
}
