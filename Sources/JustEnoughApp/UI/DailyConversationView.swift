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
            .background {
                Rectangle()
                    .fill(JustEnoughDesign.pageBackground.opacity(0.96))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.black.opacity(0.045))
                            .frame(height: 0.5)
                    }
                    .ignoresSafeArea(edges: .top)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    DailyConversationTitle()
                    DayStatHeader(day: store.selectedDay)
                    DayPager(store: store)
                    AgentMemoryStrip(memory: store.memory)
                    AgentConversationSection(
                        messages: store.selectedDay.messages,
                        entriesForMessage: store.entries(relatedTo:),
                        selectEntry: store.selectEntry
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 112)
            }

            JournalInputBar(text: $store.draftInput, addAction: store.showCapture, sendAction: store.logDraftInput)
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background {
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [
                                JustEnoughDesign.pageBackground.opacity(0),
                                JustEnoughDesign.pageBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 14)
                        Rectangle()
                            .fill(JustEnoughDesign.pageBackground)
                    }
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(.black.opacity(0.045))
                            .frame(height: 0.5)
                    }
                }
        }
    }
}

private struct DailyConversationTitle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("刚刚好")
                .editorialTitle(40)
                .padding(.top, 8)
            Text("一个懂你真实饮食的营养智能体。")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
        }
    }
}

private struct AgentConversationSection: View {
    let messages: [AgentMessage]
    let entriesForMessage: (AgentMessage) -> [FoodEntry]
    let selectEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("智能体对话")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(JustEnoughDesign.secondaryInk)
            ForEach(messages) { message in
                VStack(alignment: .leading, spacing: 10) {
                    MessageBubble(message: message)
                    InlineMealResults(entries: entriesForMessage(message)) { entry in
                        selectEntry(entry)
                    }
                }
            }
        }
    }
}

private struct DayPager: View {
    @Bindable var store: JournalStore

    var body: some View {
        HStack(spacing: 8) {
            Button(action: store.showPreviousDay) {
                Label("上一天", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(store.canShowPreviousDay ? 0.74 : 0.46), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.black.opacity(store.canShowPreviousDay ? 0.045 : 0.024), lineWidth: 0.5)
                    }
            }
            .disabled(!store.canShowPreviousDay)
            .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(store.canShowPreviousDay ? 0.96 : 0.34))

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
                                .shadow(color: day.id == store.selectedDayID ? .black.opacity(0.1) : .clear, radius: 7, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)

            Button(action: store.showNextDay) {
                Label("下一天", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(store.canShowNextDay ? 0.74 : 0.46), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.black.opacity(store.canShowNextDay ? 0.045 : 0.024), lineWidth: 0.5)
                    }
            }
            .disabled(!store.canShowNextDay)
            .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(store.canShowNextDay ? 0.96 : 0.34))
        }
        .padding(4)
        .background(Color.white.opacity(0.52), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.62), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.02), radius: 9, y: 4)
        .buttonStyle(.plain)
    }
}

private struct AgentMemoryStrip: View {
    let memory: UserNutritionMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("智能体记忆")
                .tinyCaps()
            HStack(spacing: 9) {
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
            .frame(height: 34)
            .background(Color.white.opacity(0.66), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.black.opacity(0.035), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.035), radius: 9, y: 5)
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
                    .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white.opacity(0.68), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 14, y: 8)
                }
            }
            .padding(.top, 2)
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
        .padding(4)
        .background(Color.white.opacity(0.34), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.5), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.018), radius: 7, y: 3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tracePill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(JustEnoughDesign.secondaryInk)
            .padding(.horizontal, 9)
            .frame(height: 25)
            .background(Color.white.opacity(0.42), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.56), lineWidth: 1)
            }
    }
}
