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
    var mode: Mode = .day
    var selectedDayID: String
    var selectedEntry: FoodEntry?
    var draftInput = ""
    var lastRecognizedEntry: FoodEntry?
    var streamingText = ""

    private let agent: AgentRunning
    private let nutrition: NutritionProviding
    private let visuals: FoodVisualProviding
    private let persistence: JournalPersisting

    init(
        agent: AgentRunning = LocalAgentRuntime(),
        nutrition: NutritionProviding = LocalNutritionProvider(),
        visuals: FoodVisualProviding = LocalFoodVisualProvider(),
        persistence: JournalPersisting = JSONJournalPersistence()
    ) {
        self.agent = agent
        self.nutrition = nutrition
        self.visuals = visuals
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
            name: "Avocado Garden Salad",
            servingDescription: "egg, tomato, cucumber, and crunchy topping",
            loggedAt: selectedDay.date
        )
        lastRecognizedEntry = makeEntry(from: draft)
        streamingText = "That looks like a bright salad bowl with egg, greens, tomato, cucumber, and a crunchy topping."
    }

    func acceptRecognition() {
        guard let entry = lastRecognizedEntry else { return }
        append(entry: entry, userText: "photo of my salad", agentText: "Logged Avocado Garden Salad at \(entry.estimate.calories) kcal with \(entry.estimate.macros.protein)g protein.")
        selectedEntry = nil
        mode = .day
    }

    func updateSelectedEntryCalories(_ calories: Int) {
        guard let selectedEntry else { return }
        updateEntry(selectedEntry.id) { entry in
            entry.estimate.calories = calories
            entry.estimate.rationale = "Adjusted by the user after reviewing the agent estimate."
        }
    }

    private func appendEntries(from input: String, date: Date) {
        let drafts = agent.parse(input: input, date: date, memory: memory)
        let entries = drafts.map(makeEntry(from:))
        let agentText = agent.response(for: input, entries: entries, memory: memory)
        append(entries: entries, userText: input, agentText: agentText)
    }

    private func makeEntry(from draft: AgentMealDraft) -> FoodEntry {
        FoodEntry(
            name: draft.name,
            servingDescription: draft.servingDescription,
            estimate: nutrition.estimate(for: draft, memory: memory),
            visual: visuals.visual(for: draft.name),
            loggedAt: draft.loggedAt
        )
    }

    private func append(entry: FoodEntry, userText: String, agentText: String) {
        append(entries: [entry], userText: userText, agentText: agentText)
    }

    private func append(entries: [FoodEntry], userText: String, agentText: String) {
        guard let index = days.firstIndex(where: { $0.id == selectedDayID }) else { return }
        days[index].entries.append(contentsOf: entries)
        days[index].messages.append(AgentMessage(role: .user, text: userText, createdAt: days[index].date, relatedEntryIDs: entries.map(\.id)))
        days[index].messages.append(AgentMessage(role: .agent, text: agentText, createdAt: days[index].date, relatedEntryIDs: entries.map(\.id)))
        days[index].summary = agentText
        updateMemory(with: entries)
        persist()
    }

    private func updateMemory(with entries: [FoodEntry]) {
        for entry in entries where !memory.commonFoods.contains(entry.name) {
            memory.commonFoods.append(entry.name)
        }
    }

    private func updateEntry(_ entryID: UUID, mutation: (inout FoodEntry) -> Void) {
        for dayIndex in days.indices {
            guard let entryIndex = days[dayIndex].entries.firstIndex(where: { $0.id == entryID }) else { continue }
            mutation(&days[dayIndex].entries[entryIndex])
            selectedEntry = days[dayIndex].entries[entryIndex]
            persist()
            return
        }
    }

    private func persist() {
        persistence.save(JournalSnapshot(memory: memory, days: days))
    }
}
