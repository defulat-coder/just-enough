import SwiftUI

struct AppChrome: View {
    let title: String?
    let leadingSystemName: String?
    let trailingSystemName: String?
    let leadingAction: () -> Void
    let trailingAction: () -> Void

    init(
        title: String? = nil,
        leadingSystemName: String? = nil,
        trailingSystemName: String? = "ellipsis",
        leadingAction: @escaping () -> Void = {},
        trailingAction: @escaping () -> Void = {}
    ) {
        self.title = title
        self.leadingSystemName = leadingSystemName
        self.trailingSystemName = trailingSystemName
        self.leadingAction = leadingAction
        self.trailingAction = trailingAction
    }

    var body: some View {
        HStack {
            if let leadingSystemName {
                ChromeButton(systemName: leadingSystemName, action: leadingAction)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
            Spacer()
            if let title {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            Spacer()
            if let trailingSystemName {
                ChromeButton(systemName: trailingSystemName, action: trailingAction)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

struct ChromeButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JustEnoughDesign.ink)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.7), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.black.opacity(0.05), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.045), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct DayStatHeader: View {
    let day: FoodDay
    var prominent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.eyebrow).tinyCaps()
                    Text(day.title).editorialTitle(prominent ? 46 : 31)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text(day.calories.formatted())
                            .font(.system(size: prominent ? 54 : 27, weight: .bold, design: .rounded))
                        Text("千卡")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    Text("\(day.macros.protein)g 蛋白")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                    Text(day.calorieBalanceText)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(0.78))
                }
            }
            ProgressLine(progress: day.progress)
        }
    }
}

struct ProgressLine: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = min(max(progress, 0), 1)
            let isOverflowing = progress > 1
            let progressWidth = clampedProgress > 0 ? max(proxy.size.width * clampedProgress, 18) : 0
            ZStack(alignment: .leading) {
                Capsule().fill(.black.opacity(0.055))
                Capsule()
                    .fill(JustEnoughDesign.accent)
                    .frame(width: min(progressWidth, proxy.size.width))
                    .shadow(color: JustEnoughDesign.accent.opacity(isOverflowing ? 0.22 : 0.12), radius: isOverflowing ? 6 : 4, y: 1)
                if isOverflowing {
                    Circle()
                        .fill(JustEnoughDesign.accent)
                        .frame(width: 11, height: 11)
                        .overlay {
                            Circle()
                                .stroke(JustEnoughDesign.pageBackground.opacity(0.96), lineWidth: 2.2)
                        }
                        .shadow(color: JustEnoughDesign.accent.opacity(0.24), radius: 6, y: 1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(x: -4)
                }
            }
        }
        .frame(height: 6)
    }
}

struct MacroStrip: View {
    let macros: MacroProfile

    var body: some View {
        HStack(spacing: 22) {
            macro(value: macros.protein, label: "蛋白")
            macro(value: macros.carbs, label: "碳水")
            macro(value: macros.fat, label: "脂肪")
        }
    }

    private func macro(value: Int, label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
    }
}

struct FoodImage: View {
    let visual: FoodVisual
    var hero = false

    var body: some View {
        Image(hero ? visual.heroImageName : visual.imageName)
            .resizable()
            .scaledToFit()
            .shadow(color: .black.opacity(hero ? 0.16 : 0.1), radius: hero ? 18 : 8, y: hero ? 14 : 6)
    }
}

struct MealTile: View {
    let entry: FoodEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                FoodImage(visual: entry.visual)
                    .frame(height: 94)
                Text(entry.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("\(entry.estimate.calories) 千卡")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(JustEnoughDesign.secondaryInk)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MealRow: View {
    let entry: FoodEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.62))
                    FoodImage(visual: entry.visual)
                        .padding(4)
                }
                .frame(width: 96, height: 72)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.66), lineWidth: 1)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(entry.servingDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                        .lineLimit(1)
                    Text("\(entry.estimate.calories) 千卡   \(entry.estimate.macros.shortText)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(0.36))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MessageBubble: View {
    let message: AgentMessage

    var body: some View {
        if message.role == .agent {
            Text(message.text)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .lineSpacing(4)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(JustEnoughDesign.ink)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(message.text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(JustEnoughDesign.ink)
                .padding(.horizontal, 17)
                .padding(.vertical, 13)
                .background {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(JustEnoughDesign.blush.opacity(0.36))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(.white.opacity(0.64), lineWidth: 1)
                        }
                        .shadow(color: JustEnoughDesign.blush.opacity(0.1), radius: 10, y: 5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct JournalInputBar: View {
    @Binding var text: String
    let addAction: () -> Void
    let sendAction: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button(action: addAction) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(JustEnoughDesign.ink)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.94), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.black.opacity(0.055), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
            }
            .accessibilityIdentifier("AddMeal")

            HStack(alignment: .bottom, spacing: 8) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("写下吃了什么，或加照片")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(0.52))
                            .allowsHitTesting(false)
                    }
                    TextField("", text: $text, axis: .vertical)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.ink)
                        .textInputAutocapitalization(.sentences)
                        .lineLimit(1...3)
                        .accessibilityIdentifier("MealInput")
                }
                .padding(.vertical, 10)
                Button(action: sendAction) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(JustEnoughDesign.accent, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        }
                        .shadow(color: JustEnoughDesign.accent.opacity(0.18), radius: 8, y: 4)
                }
                .accessibilityIdentifier("SendMeal")
                .padding(.bottom, 7)
            }
            .padding(.leading, 17)
            .padding(.trailing, 7)
            .frame(minHeight: 54)
            .background(Color.white.opacity(0.92), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.035), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.045), radius: 12, y: 6)
        }
    }
}
