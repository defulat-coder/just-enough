import SwiftUI

struct FoodDetailView: View {
    @Bindable var store: JournalStore
    @State private var calories: Double
    let entry: FoodEntry

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
                .blur(radius: 10)
                .opacity(0.34)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Color.clear.frame(height: 16)
                    titleBlock
                    FoodImage(visual: entry.visual, hero: true)
                        .frame(height: 275)
                    nutritionBlock
                    estimateSourceBlock
                    editBlock
                    rationaleBlock
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 42)
            }
        }
        .premiumPage()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var titleBlock: some View {
        VStack(spacing: 7) {
            Text(entry.name)
                .editorialTitle(34)
                .multilineTextAlignment(.center)
            Text(entry.servingDescription)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
    }

    private var nutritionBlock: some View {
        VStack(spacing: 10) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(Int(calories).formatted())
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("cal")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            MacroStrip(macros: entry.estimate.macros)
        }
    }

    private var editBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Adjust estimate")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(JustEnoughDesign.secondaryInk)
                .textCase(.uppercase)
            Slider(value: $calories, in: 80...1_200, step: 10) {
                Text("Calories")
            } minimumValueLabel: {
                Text("80")
            } maximumValueLabel: {
                Text("1200")
            }
            Button("Save calorie adjustment") {
                store.updateSelectedEntryCalories(Int(calories))
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: 260)
            .padding(.vertical, 13)
            .background(JustEnoughDesign.accent, in: Capsule())
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityIdentifier("SaveCalorieAdjustment")
        }
    }

    private var estimateSourceBlock: some View {
        HStack(spacing: 8) {
            sourcePill(entry.estimate.source)
            sourcePill("\(Int(entry.estimate.confidence * 100))% confidence")
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func sourcePill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private var rationaleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Agent rationale")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(JustEnoughDesign.secondaryInk)
                .textCase(.uppercase)
            Text(entry.estimate.rationale)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .lineSpacing(4)
            Text("Source: \(entry.estimate.source) · \(Int(entry.estimate.confidence * 100))% confidence")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
