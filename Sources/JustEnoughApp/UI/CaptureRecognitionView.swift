import SwiftUI

struct CaptureRecognitionView: View {
    @Bindable var store: JournalStore

    var body: some View {
        ZStack {
            Image("camera-salad")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.08))

            VStack {
                AppChrome(
                    leadingSystemName: "xmark",
                    trailingSystemName: nil,
                    leadingAction: { store.mode = .day }
                )
                Spacer()
                HStack(alignment: .bottom) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(JustEnoughDesign.accent, in: Capsule())
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(8)
                    .background(.black.opacity(0.42), in: Capsule())

                    Spacer()
                    Button(action: store.capturePhoto) {
                        Circle()
                            .fill(.white)
                            .frame(width: 78, height: 78)
                            .overlay(Circle().stroke(.white.opacity(0.64), lineWidth: 8))
                            .shadow(color: .black.opacity(0.28), radius: 16, y: 8)
                    }
                    .accessibilityIdentifier("CaptureMeal")
                    Spacer()
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
    }
}

struct RecognitionReviewView: View {
    @Bindable var store: JournalStore

    var body: some View {
        VStack(spacing: 0) {
            AppChrome(
                leadingSystemName: "chevron.left",
                trailingSystemName: nil,
                leadingAction: { store.mode = .capture }
            )
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text(store.streamingText)
                        .font(.system(size: 21, weight: .regular, design: .rounded))
                        .lineSpacing(4)
                        .padding(.top, 16)

                    RecognitionTrace()

                    Image("salad-photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 255, height: 255)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    if let entry = store.lastRecognizedEntry {
                        MealRow(entry: entry) {
                            store.acceptRecognition()
                        }
                        .accessibilityIdentifier("RecognizedMeal")

                        Button("Accept and return to thread") {
                            store.acceptRecognition()
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(JustEnoughDesign.accent, in: Capsule())
                        .accessibilityIdentifier("AcceptRecognizedMeal")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .premiumPage()
    }
}

private struct RecognitionTrace: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Agent analysis")
                .tinyCaps()
            HStack(spacing: 7) {
                tracePill("vision")
                tracePill("memory")
                tracePill("nutrition DB")
            }
        }
    }

    private func tracePill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 10)
            .frame(height: 27)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
