import SwiftUI

struct TimelineCatalogView: View {
    @Bindable var store: JournalStore

    var body: some View {
        VStack(spacing: 0) {
            AppChrome(
                title: "饮食图册",
                leadingSystemName: "chevron.left",
                trailingSystemName: nil,
                leadingAction: store.returnToDay
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    TimelineCatalogHeader(
                        dayCount: store.days.count,
                        totalLoggedCalories: store.totalLoggedCalories
                    )
                    ForEach(store.days) { day in
                        TimelineDaySection(
                            day: day,
                            openDay: store.showDay,
                            selectEntry: store.selectEntry
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 42)
            }
        }
    }
}

private struct TimelineCatalogHeader: View {
    let dayCount: Int
    let totalLoggedCalories: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("把每一餐拉远成一本安静的图册。")
                .editorialTitle(34)
            Text("来自 \(dayCount) 个智能体线程 · 已记录 \(totalLoggedCalories.formatted()) 千卡")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
        .padding(.top, 8)
    }
}

private struct TimelineDaySection: View {
    let day: FoodDay
    let openDay: (FoodDay) -> Void
    let selectEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                openDay(day)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    DayStatHeader(day: day)
                    Text("打开\(day.title)的对话")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                }
            }
            .buttonStyle(.plain)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)], spacing: 22) {
                ForEach(day.entries) { entry in
                    Button {
                        selectEntry(entry)
                    } label: {
                        TimelineMealTile(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TimelineMealTile: View {
    let entry: FoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .shadow(color: .black.opacity(0.05), radius: 12, y: 8)
                FoodImage(visual: entry.visual)
                    .padding(10)
            }
            .frame(height: 138)
            .frame(maxWidth: .infinity)
            Text(entry.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .lineLimit(2)
            Text("\(entry.estimate.calories) 千卡")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
