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
                Color.clear.frame(width: 42, height: 42)
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
                Color.clear.frame(width: 42, height: 42)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct ChromeButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(JustEnoughDesign.ink)
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.08), radius: 9, y: 5)
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
            ZStack(alignment: .leading) {
                Capsule().fill(.black.opacity(0.08))
                Capsule()
                    .fill(JustEnoughDesign.accent)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 4)
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
            HStack(spacing: 16) {
                FoodImage(visual: entry.visual)
                    .frame(width: 104, height: 78)
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.name)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(entry.servingDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                        .lineLimit(1)
                    Text("\(entry.estimate.calories) 千卡   \(entry.estimate.macros.shortText)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MessageBubble: View {
    let message: AgentMessage

    var body: some View {
        Text(message.text)
            .font(.system(size: message.role == .agent ? 17 : 15, weight: message.role == .agent ? .regular : .semibold, design: .rounded))
            .lineSpacing(4)
            .lineLimit(message.role == .agent ? 3 : nil)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(JustEnoughDesign.ink)
            .padding(.horizontal, message.role == .agent ? 0 : 17)
            .padding(.vertical, message.role == .agent ? 4 : 13)
            .frame(maxWidth: message.role == .agent ? .infinity : 290, alignment: message.role == .agent ? .leading : .trailing)
            .background {
                if message.role == .user {
                    Capsule().fill(JustEnoughDesign.blush.opacity(0.55))
                }
            }
            .frame(maxWidth: .infinity, alignment: message.role == .agent ? .leading : .trailing)
    }
}

struct JournalInputBar: View {
    @Binding var text: String
    let addAction: () -> Void
    let sendAction: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            Button(action: addAction) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(JustEnoughDesign.ink)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityIdentifier("AddMeal")

            HStack(spacing: 8) {
                TextField("写下吃了什么，或加照片", text: $text, axis: .vertical)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .textInputAutocapitalization(.sentences)
                    .lineLimit(1...3)
                    .accessibilityIdentifier("MealInput")
                Button(action: sendAction) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(JustEnoughDesign.accent, in: Circle())
                }
                .accessibilityIdentifier("SendMeal")
            }
            .padding(.leading, 17)
            .padding(.trailing, 8)
            .frame(minHeight: 52)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}
