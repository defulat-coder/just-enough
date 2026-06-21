import SwiftUI

struct FoodDetailView: View {
    @Bindable var store: JournalStore
    let entry: FoodEntry
    @State private var calories: Double

    init(store: JournalStore, entry: FoodEntry) {
        self.store = store
        self.entry = entry
        _calories = State(initialValue: Double(entry.estimate.calories))
    }

    var body: some View {
        ZStack {
            Image(entry.visual.backgroundImageName)
                .resizable()
                .scaledToFill()
                .blur(radius: 16)
                .opacity(0.24)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 24)
                    FoodDetailTitleSection(entry: entry)
                    FoodDetailHeroImage(visual: entry.visual)
                    FoodDetailNutritionSection(entry: entry, calories: calories)
                    FoodDetailEstimateSourceSection(estimate: entry.estimate)
                    CalorieAdjustmentSection(calories: $calories, saveAction: saveCalories)
                    FoodDetailRationaleSection(estimate: entry.estimate)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            VStack {
                LinearGradient(
                    colors: [
                        JustEnoughDesign.pageBackground.opacity(0.92),
                        JustEnoughDesign.pageBackground.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 76)
                Spacer()
            }
            .allowsHitTesting(false)
            .ignoresSafeArea(edges: .top)
        }
        .premiumPage()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func saveCalories() {
        store.updateSelectedEntryCalories(Int(calories))
    }
}

private struct FoodDetailHeroImage: View {
    let visual: FoodVisual

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.42))
            Image(visual.heroImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 188)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(9)
        }
        .frame(height: 208)
        .frame(maxWidth: 304)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.5), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.085), radius: 16, y: 10)
    }
}

private struct FoodDetailTitleSection: View {
    let entry: FoodEntry

    var body: some View {
        VStack(spacing: 7) {
            Text(entry.name)
                .editorialTitle(32)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
            Text(entry.servingDescription)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 8)
    }
}

private struct FoodDetailNutritionSection: View {
    let entry: FoodEntry
    let calories: Double

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(Int(calories).formatted())
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                Text("千卡")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            FoodDetailMacroStrip(macros: entry.estimate.macros)
        }
    }
}

private struct FoodDetailMacroStrip: View {
    let macros: MacroProfile

    var body: some View {
        HStack(spacing: 8) {
            macro(value: macros.protein, label: "蛋白")
            macro(value: macros.carbs, label: "碳水")
            macro(value: macros.fat, label: "脂肪")
        }
    }

    private func macro(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
        .frame(width: 58, height: 44)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(.black.opacity(0.035), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.025), radius: 7, y: 4)
    }
}

private struct CalorieAdjustmentSection: View {
    @Binding var calories: Double
    let saveAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            HStack(alignment: .center) {
                Text("调整估算")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(JustEnoughDesign.secondaryInk)
                Spacer()
                Text("\(Int(calories)) 千卡")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(JustEnoughDesign.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.white.opacity(0.58), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.black.opacity(0.035), lineWidth: 0.5)
                    }
            }
            .frame(maxWidth: 284)
            Slider(value: $calories, in: 80...1_200, step: 10) {
                Text("热量")
            }
            .tint(JustEnoughDesign.accent)
            .padding(.horizontal, 10)
            .frame(maxWidth: 284)
            .frame(height: 36)
            .background(Color.white.opacity(0.44), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.026), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.02), radius: 8, y: 4)
            Button("保存热量调整", action: saveAction)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: 276)
            .padding(.vertical, 13)
            .background(JustEnoughDesign.accent, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(color: JustEnoughDesign.accent.opacity(0.2), radius: 10, y: 5)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityIdentifier("SaveCalorieAdjustment")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .frame(maxWidth: 320)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.66), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 16, y: 9)
        .frame(maxWidth: .infinity)
    }
}

private struct FoodDetailEstimateSourceSection: View {
    let estimate: NutritionEstimate

    var body: some View {
        HStack(spacing: 8) {
            FoodDetailSourcePill(text: estimate.source)
            FoodDetailSourcePill(text: "\(Int(estimate.confidence * 100))% 置信度")
        }
        .padding(6)
        .background(Color.white.opacity(0.5), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.62), lineWidth: 1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct FoodDetailSourcePill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Color.white.opacity(0.54), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.035), lineWidth: 0.5)
            }
    }
}

private struct FoodDetailRationaleSection: View {
    let estimate: NutritionEstimate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(JustEnoughDesign.accent)
                    .frame(width: 25, height: 25)
                    .background(Color.white.opacity(0.62), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(JustEnoughDesign.accent.opacity(0.12), lineWidth: 1)
                    }
                Text("智能体判断依据")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(JustEnoughDesign.ink)
                Spacer()
            }
            Text(estimate.rationale)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .lineSpacing(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 7) {
                rationalePill("来源 \(estimate.source)")
                rationalePill("\(Int(estimate.confidence * 100))% 置信度")
            }
            .padding(.top, 1)
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: 320, alignment: .leading)
        .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 16, y: 9)
        .frame(maxWidth: .infinity)
    }

    private func rationalePill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 10)
            .frame(height: 27)
            .background(Color.white.opacity(0.56), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.035), lineWidth: 0.5)
            }
    }
}
