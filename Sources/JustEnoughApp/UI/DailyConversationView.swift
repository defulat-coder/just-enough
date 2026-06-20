import SwiftUI

struct DailyConversationView: View {
    @Bindable var store: JournalStore

    var body: some View {
        VStack(spacing: 0) {
            AppChrome(
                title: nil,
                leadingSystemName: nil,
                trailingSystemName: "square.grid.2x2",
                trailingAction: store.showTimeline
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    title
                    DayStatHeader(day: store.selectedDay)
                    DayPager(store: store)
                    AgentMemoryStrip(memory: store.memory)
                    conversation
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 116)
            }

            JournalInputBar(text: $store.draftInput, addAction: store.showCapture, sendAction: store.logDraftInput)
                .padding(.horizontal, 18)
                .padding(.bottom, 8)
                .background(JustEnoughDesign.pageBackground.opacity(0.75))
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("刚刚好")
                .editorialTitle(40)
                .padding(.top, 8)
            Text("一个懂你真实饮食的营养智能体。")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
    }

    private var conversation: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("智能体对话")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
            ForEach(store.selectedDay.messages) { message in
                VStack(alignment: .leading, spacing: 12) {
                    MessageBubble(message: message)
                    InlineMealResults(entries: store.entries(relatedTo: message)) { entry in
                        store.selectEntry(entry)
                    }
                }
            }
        }
    }
}

private struct DayPager: View {
    @Bindable var store: JournalStore

    var body: some View {
        HStack(spacing: 10) {
            Button(action: store.showPreviousDay) {
                Label("上一天", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .disabled(!store.canShowPreviousDay)
            .opacity(store.canShowPreviousDay ? 1 : 0.32)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.days) { day in
                        Button {
                            store.showDay(day)
                        } label: {
                            Text(day.pagerTitle)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding(.horizontal, 13)
                                .frame(height: 36)
                                .background(day.id == store.selectedDayID ? JustEnoughDesign.ink : .clear, in: Capsule())
                                .foregroundStyle(day.id == store.selectedDayID ? JustEnoughDesign.pageBackground : JustEnoughDesign.secondaryInk)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Button(action: store.showNextDay) {
                Label("下一天", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .disabled(!store.canShowNextDay)
            .opacity(store.canShowNextDay ? 1 : 0.32)
        }
        .buttonStyle(.plain)
    }
}

private struct AgentMemoryStrip: View {
    let memory: UserNutritionMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("智能体记忆")
                .tinyCaps()
            HStack(spacing: 8) {
                memoryPill("\(memory.dailyProteinTarget)g 蛋白")
                memoryPill("训练优先")
                memoryPill("\(memory.commonFoods.count) 个常吃")
            }
        }
        .padding(.vertical, 2)
    }

    private func memoryPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

private struct InlineMealResults: View {
    let entries: [FoodEntry]
    let action: (FoodEntry) -> Void

    var body: some View {
        if !entries.isEmpty {
            VStack(spacing: 10) {
                AgentToolTrace(entryCount: entries.count)
                ForEach(entries) { entry in
                    MealRow(entry: entry) {
                        action(entry)
                    }
                    .padding(10)
                    .background(JustEnoughDesign.glass, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

private struct AgentToolTrace: View {
    let entryCount: Int

    var body: some View {
        HStack(spacing: 7) {
            tracePill("流式")
            tracePill("记忆")
            tracePill("营养库")
            tracePill("\(entryCount) 个食物")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tracePill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 9)
            .frame(height: 25)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
