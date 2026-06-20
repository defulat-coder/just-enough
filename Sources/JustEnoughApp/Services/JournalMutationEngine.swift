import Foundation

struct JournalMutationEngine {
    private let nutrition: NutritionProviding
    private let visuals: FoodVisualProviding

    init(
        nutrition: NutritionProviding = LocalNutritionProvider(),
        visuals: FoodVisualProviding = LocalFoodVisualProvider()
    ) {
        self.nutrition = nutrition
        self.visuals = visuals
    }

    func entries(from drafts: [AgentMealDraft], memory: UserNutritionMemory) -> [FoodEntry] {
        drafts.map { draft in
            FoodEntry(
                name: draft.name,
                servingDescription: draft.servingDescription,
                estimate: nutrition.estimate(for: draft, memory: memory),
                visual: visuals.visual(for: draft.name),
                loggedAt: draft.loggedAt
            )
        }
    }

    @discardableResult
    func record(
        entries: [FoodEntry],
        userText: String,
        agentText: String,
        selectedDayID: String,
        days: inout [FoodDay],
        memory: inout UserNutritionMemory
    ) -> Bool {
        guard let index = days.firstIndex(where: { $0.id == selectedDayID }) else { return false }

        let relatedEntryIDs = entries.map(\.id)
        days[index].entries.append(contentsOf: entries)
        days[index].messages.append(
            AgentMessage(
                role: .user,
                text: userText,
                createdAt: days[index].date,
                relatedEntryIDs: relatedEntryIDs
            )
        )
        days[index].messages.append(
            AgentMessage(
                role: .agent,
                text: agentText,
                createdAt: days[index].date,
                relatedEntryIDs: relatedEntryIDs
            )
        )
        days[index].summary = agentText
        remember(entries: entries, memory: &memory)
        return true
    }

    func updateEntry(
        _ entryID: UUID,
        days: inout [FoodDay],
        mutation: (inout FoodEntry) -> Void
    ) -> FoodEntry? {
        for dayIndex in days.indices {
            guard let entryIndex = days[dayIndex].entries.firstIndex(where: { $0.id == entryID }) else { continue }
            mutation(&days[dayIndex].entries[entryIndex])
            return days[dayIndex].entries[entryIndex]
        }

        return nil
    }

    private func remember(entries: [FoodEntry], memory: inout UserNutritionMemory) {
        for entry in entries where !memory.commonFoods.contains(entry.name) {
            memory.commonFoods.append(entry.name)
        }
    }
}
