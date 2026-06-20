import Foundation
import Observation

@Observable
final class JournalStore {
    enum Mode: Equatable {
        case day
        case timeline
        case capture
        case recognition
    }

    var days: [FoodDay]
    var memory: UserNutritionMemory
    private(set) var mode: Mode = .day
    var selectedDayID: String
    var selectedEntry: FoodEntry?
    var draftInput = ""
    var lastRecognizedEntry: FoodEntry?
    var streamingText = ""

    private let agent: AgentRunning
    private let mutations: JournalMutationEngine
    private let persistence: JournalPersisting

    init(
        agent: AgentRunning = LocalAgentRuntime(),
        nutrition: NutritionProviding = LocalNutritionProvider(),
        visuals: FoodVisualProviding = LocalFoodVisualProvider(),
        persistence: JournalPersisting = JSONJournalPersistence()
    ) {
        self.agent = agent
        self.mutations = JournalMutationEngine(nutrition: nutrition, visuals: visuals)
        self.persistence = persistence

        let shouldReset = ProcessInfo.processInfo.arguments.contains("--reset-journal")
        let snapshot = shouldReset ? JournalFixtures.initialSnapshot : persistence.load() ?? JournalFixtures.initialSnapshot
        self.days = snapshot.days
        self.memory = snapshot.memory
        self.selectedDayID = snapshot.days.first?.id ?? JournalFixtures.initialSnapshot.days[0].id
        if shouldReset {
            persistence.save(snapshot)
        }
    }

    var selectedDay: FoodDay {
        days.first(where: { $0.id == selectedDayID }) ?? days[0]
    }

    var totalLoggedCalories: Int {
        days.reduce(0) { $0 + $1.calories }
    }

    var selectedDayIndex: Int {
        days.firstIndex(where: { $0.id == selectedDayID }) ?? 0
    }

    var canShowPreviousDay: Bool {
        selectedDayIndex < days.count - 1
    }

    var canShowNextDay: Bool {
        selectedDayIndex > 0
    }

    func showPreviousDay() {
        let nextIndex = min(selectedDayIndex + 1, days.count - 1)
        showDay(days[nextIndex])
    }

    func showNextDay() {
        let nextIndex = max(selectedDayIndex - 1, 0)
        showDay(days[nextIndex])
    }

    func entries(relatedTo message: AgentMessage) -> [FoodEntry] {
        if !message.relatedEntryIDs.isEmpty {
            return selectedDay.entries.filter { message.relatedEntryIDs.contains($0.id) }
        }

        guard message.role == .agent,
              selectedDay.messages.first(where: { $0.role == .agent })?.id == message.id
        else {
            return []
        }

        return Array(selectedDay.entries.prefix(4))
    }

    func showDay(_ day: FoodDay) {
        selectedDayID = day.id
        mode = .day
    }

    func showTimeline() {
        mode = .timeline
    }

    func showCapture() {
        mode = .capture
    }

    func returnToCapture() {
        mode = .capture
    }

    func returnToDay() {
        mode = .day
    }

    func selectEntry(_ entry: FoodEntry) {
        selectedEntry = entry
    }

    func closeDetail() {
        selectedEntry = nil
    }

    func logDraftInput() {
        let input = draftInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        draftInput = ""
        appendEntries(from: input, date: selectedDay.date)
    }

    func capturePhoto() {
        mode = .recognition
        let draft = AgentMealDraft(
            name: "牛油果花园沙拉",
            servingDescription: "鸡蛋、番茄、黄瓜和脆脆配料",
            loggedAt: selectedDay.date
        )
        lastRecognizedEntry = mutations.entries(from: [draft], memory: memory).first
        streamingText = "看起来是一份明亮的沙拉碗，有鸡蛋、绿叶菜、番茄、黄瓜和脆脆配料。"
    }

    func acceptRecognition() {
        guard let entry = lastRecognizedEntry else { return }
        append(entry: entry, userText: "我的沙拉照片", agentText: "已记录牛油果花园沙拉：\(entry.estimate.calories) 千卡，\(entry.estimate.macros.protein)g 蛋白。")
        selectedEntry = nil
        mode = .day
    }

    func updateSelectedEntryCalories(_ calories: Int) {
        guard let selectedEntry else { return }
        updateEntry(selectedEntry.id) { entry in
            entry.estimate.calories = calories
            entry.estimate.rationale = "用户复核智能体估算后手动调整。"
        }
    }

    private func appendEntries(from input: String, date: Date) {
        let drafts = agent.parse(input: input, date: date, memory: memory)
        let entries = mutations.entries(from: drafts, memory: memory)
        let agentText = agent.response(for: input, entries: entries, memory: memory)
        append(entries: entries, userText: input, agentText: agentText)
    }

    private func append(entry: FoodEntry, userText: String, agentText: String) {
        append(entries: [entry], userText: userText, agentText: agentText)
    }

    private func append(entries: [FoodEntry], userText: String, agentText: String) {
        if mutations.record(entries: entries, userText: userText, agentText: agentText, selectedDayID: selectedDayID, days: &days, memory: &memory) {
            persist()
        }
    }

    private func updateEntry(_ entryID: UUID, mutation: (inout FoodEntry) -> Void) {
        if let updatedEntry = mutations.updateEntry(entryID, days: &days, mutation: mutation) {
            selectedEntry = updatedEntry
            persist()
        }
    }

    private func persist() {
        persistence.save(JournalSnapshot(memory: memory, days: days))
    }
}
