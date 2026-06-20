import SwiftUI

struct JournalAppView: View {
    @Bindable var store: JournalStore

    var body: some View {
        ZStack {
            switch store.mode {
            case .day:
                DailyConversationView(store: store)
            case .timeline:
                TimelineCatalogView(store: store)
            case .capture:
                CaptureRecognitionView(store: store)
            case .recognition:
                RecognitionReviewView(store: store)
            }
        }
        .animation(JustEnoughDesign.spring, value: store.mode)
        .sheet(item: $store.selectedEntry) { entry in
            FoodDetailView(store: store, entry: entry)
        }
        .premiumPage()
    }
}
