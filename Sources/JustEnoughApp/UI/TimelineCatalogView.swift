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
                VStack(alignment: .leading, spacing: 22) {
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
                .padding(.bottom, 52)
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
                .editorialTitle(28)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
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
        VStack(alignment: .leading, spacing: 14) {
            Button {
                openDay(day)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    DayStatHeader(day: day)
                    HStack(spacing: 5) {
                        Text("打开\(day.title)的对话")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(JustEnoughDesign.ink)
                    .padding(.horizontal, 13)
                    .frame(height: 32)
                    .background(Color.white.opacity(0.84), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.black.opacity(0.045), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.045), radius: 8, y: 4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .buttonStyle(.plain)

            TimelineMealGrid(entries: day.entries, selectEntry: selectEntry)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.44), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.62), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.028), radius: 14, y: 8)
    }
}

private struct TimelineMealGrid: View {
    let entries: [FoodEntry]
    let selectEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows.indices, id: \.self) { index in
                let row = rows[index]
                if row.count == 1, let entry = row.first {
                    HStack {
                        Spacer(minLength: 0)
                        tileButton(entry)
                            .frame(maxWidth: 164)
                        Spacer(minLength: 0)
                    }
                } else {
                    HStack(spacing: 12) {
                        ForEach(row) { entry in
                            tileButton(entry)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private var rows: [[FoodEntry]] {
        stride(from: 0, to: entries.count, by: 2).map { index in
            Array(entries[index..<min(index + 2, entries.count)])
        }
    }

    private func tileButton(_ entry: FoodEntry) -> some View {
        Button {
            selectEntry(entry)
        } label: {
            TimelineMealTile(entry: entry)
        }
        .buttonStyle(.plain)
    }
}

private struct TimelineMealTile: View {
    let entry: FoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.black.opacity(0.028), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.032), radius: 11, y: 6)
                    .overlay {
                        FoodImage(visual: entry.visual)
                            .padding(7)
                    }
                    .frame(height: 112)
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text("\(entry.estimate.calories) 千卡")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(JustEnoughDesign.secondaryInk)
                }
                .frame(minHeight: 34, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(7)
            .background(Color.white.opacity(0.46), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .stroke(.white.opacity(0.58), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.018), radius: 8, y: 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
