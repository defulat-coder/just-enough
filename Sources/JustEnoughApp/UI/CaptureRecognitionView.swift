import SwiftUI

struct CaptureRecognitionView: View {
    @Bindable var store: JournalStore

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("camera-salad")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.12))
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [.black.opacity(0.34), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 180)
                    }
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.38),
                                .black.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 390)
                    }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    CaptureIconButton(systemName: "xmark", action: store.returnToDay)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)

                Spacer()
                ZStack {
                    Button(action: store.capturePhoto) {
                        Circle()
                            .fill(.white.opacity(0.96))
                            .frame(width: 78, height: 78)
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.92), lineWidth: 5)
                                    .padding(5)
                            }
                            .overlay {
                                Circle()
                                    .stroke(.black.opacity(0.08), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.34), radius: 18, y: 9)
                    }
                    .accessibilityIdentifier("CaptureMeal")

                    HStack(alignment: .bottom) {
                        HStack(spacing: 9) {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(JustEnoughDesign.accent, in: Circle())
                                .shadow(color: JustEnoughDesign.accent.opacity(0.24), radius: 8, y: 4)
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.82))
                                .frame(width: 38, height: 38)
                                .background(.white.opacity(0.1), in: Circle())
                        }
                        .padding(6)
                        .background(.black.opacity(0.56), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                        .frame(width: 104, alignment: .leading)

                        Spacer()

                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(.black.opacity(0.56), in: Circle())
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.22), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 11, y: 6)
                            .frame(width: 104, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 82)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct RecognitionReviewView: View {
    @Bindable var store: JournalStore

    var body: some View {
        VStack(spacing: 0) {
            AppChrome(
                title: "识别结果",
                leadingSystemName: "chevron.left",
                trailingSystemName: nil,
                leadingAction: store.returnToCapture
            )
            .background {
                Rectangle()
                    .fill(JustEnoughDesign.pageBackground.opacity(0.96))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.black.opacity(0.05))
                            .frame(height: 0.5)
                    }
                    .ignoresSafeArea(edges: .top)
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(store.streamingText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .lineSpacing(5)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 17)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 21, style: .continuous)
                                .stroke(.black.opacity(0.035), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.04), radius: 13, y: 7)
                        .padding(.top, 14)

                    RecognitionTrace()

                    Image("salad-photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 238, height: 238)
                        .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 23, style: .continuous)
                                .stroke(.white.opacity(0.66), lineWidth: 1)
                        }
                        .padding(9)
                        .background(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 27, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .stroke(.white.opacity(0.58), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.055), radius: 15, y: 9)
                        .frame(maxWidth: .infinity, alignment: .center)

                    if let entry = store.lastRecognizedEntry {
                        MealRow(entry: entry) {
                            store.acceptRecognition()
                        }
                        .padding(9)
                        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 23, style: .continuous)
                                .stroke(.white.opacity(0.62), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.04), radius: 13, y: 7)
                        .accessibilityIdentifier("RecognizedMeal")

                        Button("接受并回到对话") {
                            store.acceptRecognition()
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 276)
                        .padding(.vertical, 13)
                        .background(JustEnoughDesign.accent, in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        }
                        .shadow(color: JustEnoughDesign.accent.opacity(0.2), radius: 11, y: 6)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityIdentifier("AcceptRecognizedMeal")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 46)
            }
        }
        .premiumPage()
    }
}

private struct CaptureIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.black.opacity(0.54), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.22), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("关闭拍照")
    }
}

private struct RecognitionTrace: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("智能体分析")
                .tinyCaps()
            HStack(spacing: 7) {
                tracePill("视觉识别")
                tracePill("记忆")
                tracePill("营养库")
            }
            .padding(5)
            .background(Color.white.opacity(0.5), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.66), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.02), radius: 8, y: 4)
        }
    }

    private func tracePill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 10)
            .frame(height: 27)
            .background(Color.white.opacity(0.58), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.035), lineWidth: 0.5)
            }
    }
}
