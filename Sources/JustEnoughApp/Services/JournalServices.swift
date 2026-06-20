import Foundation

protocol NutritionProviding {
    func estimate(for draft: AgentMealDraft, memory: UserNutritionMemory) -> NutritionEstimate
}

protocol FoodVisualProviding {
    func visual(for foodName: String) -> FoodVisual
}

protocol AgentRunning {
    func parse(input: String, date: Date, memory: UserNutritionMemory) -> [AgentMealDraft]
    func response(for input: String, entries: [FoodEntry], memory: UserNutritionMemory) -> String
}

protocol JournalPersisting {
    func load() -> JournalSnapshot?
    func save(_ snapshot: JournalSnapshot)
}

struct LocalNutritionProvider: NutritionProviding {
    func estimate(for draft: AgentMealDraft, memory: UserNutritionMemory) -> NutritionEstimate {
        let normalized = draft.name.lowercased()
        let known: (Int, MacroProfile, String)

        if normalized.contains("pancake") {
            known = (520, MacroProfile(protein: 10, carbs: 68, fat: 18), "Pancake estimate matched from breakfast history.")
        } else if normalized.contains("latte") || normalized.contains("coffee") {
            known = (180, MacroProfile(protein: 6, carbs: 22, fat: 6), "Latte estimate matched to oat milk preference.")
        } else if normalized.contains("yogurt") {
            known = (210, MacroProfile(protein: 24, carbs: 18, fat: 4), "Greek yogurt estimate matched to high-protein snack history.")
        } else if normalized.contains("egg") {
            known = (220, MacroProfile(protein: 18, carbs: 2, fat: 15), "Egg estimate matched to a three-egg serving.")
        } else if normalized.contains("chicken") {
            known = (540, MacroProfile(protein: 48, carbs: 45, fat: 14), "Chicken rice estimate uses a lifting-day serving size.")
        } else if normalized.contains("salmon") {
            known = (620, MacroProfile(protein: 41, carbs: 43, fat: 30), "Salmon plate estimate includes rice and extra vegetables.")
        } else if normalized.contains("avocado") || normalized.contains("salad") || normalized.contains("greens") {
            known = (430, MacroProfile(protein: 15, carbs: 38, fat: 25), "Salad estimate inferred from greens, egg, avocado, and crunchy topping.")
        } else {
            known = (460, MacroProfile(protein: 24, carbs: 42, fat: 18), "Fallback estimate from current calorie target and common meal size.")
        }

        return NutritionEstimate(
            calories: known.0,
            macros: known.1,
            confidence: normalized.contains("unknown") ? 0.55 : 0.84,
            source: "USDA-style local nutrition",
            rationale: known.2
        )
    }
}

struct LocalFoodVisualProvider: FoodVisualProviding {
    func visual(for foodName: String) -> FoodVisual {
        let normalized = foodName.lowercased()
        if normalized.contains("pancake") {
            return FoodVisual(imageName: "pancakes", heroImageName: "pancakes-hero", backgroundImageName: "warm-detail-bg")
        }
        if normalized.contains("latte") || normalized.contains("coffee") {
            return FoodVisual(imageName: "latte", heroImageName: "latte", backgroundImageName: "warm-detail-bg")
        }
        if normalized.contains("salmon") {
            return FoodVisual(imageName: "salmon", heroImageName: "salmon", backgroundImageName: "camera-bg")
        }
        if normalized.contains("salad") || normalized.contains("greens") || normalized.contains("avocado") {
            return FoodVisual(imageName: "avocado-salad", heroImageName: "salad-photo", backgroundImageName: "camera-bg")
        }
        return FoodVisual(imageName: "greens", heroImageName: "greens", backgroundImageName: "camera-bg")
    }
}

struct LocalAgentRuntime: AgentRunning {
    func parse(input: String, date: Date, memory: UserNutritionMemory) -> [AgentMealDraft] {
        let normalized = input.lowercased()
        var drafts: [AgentMealDraft] = []

        func append(_ name: String, _ serving: String) {
            drafts.append(AgentMealDraft(name: name, servingDescription: serving, loggedAt: date))
        }

        if normalized.contains("pancake") {
            append("Blueberry Pancakes", "fluffy stack, maple syrup")
        }
        if normalized.contains("latte") || normalized.contains("coffee") {
            append("Cafe Latte", "iced, oat milk")
        }
        if normalized.contains("yogurt") {
            append("Greek Yogurt Bowl", "berries, honey, high-protein yogurt")
        }
        if normalized.contains("egg") {
            append("Soft Eggs", "three eggs, simple seasoning")
        }
        if normalized.contains("chicken") || normalized.contains("rice") {
            append("Chicken Rice Bowl", "chicken, rice, vegetables")
        }
        if normalized.contains("salmon") {
            append("Grilled Salmon Plate", "salmon, rice, extra vegetables")
        }
        if normalized.contains("salad") || normalized.contains("greens") || normalized.contains("avocado") {
            append("Avocado Garden Salad", "egg, tomato, cucumber, and crunchy topping")
        }
        if drafts.isEmpty {
            append(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Balanced Plate" : input, "agent-estimated serving")
        }
        return drafts
    }

    func response(for input: String, entries: [FoodEntry], memory: UserNutritionMemory) -> String {
        let calories = entries.reduce(0) { $0 + $1.estimate.calories }
        let protein = entries.reduce(0) { $0 + $1.estimate.macros.protein }
        let names = entries.map(\.name).joined(separator: ", ")
        let proteinGap = max(memory.dailyProteinTarget - protein, 0)
        return "Logged \(names). Streaming estimate: \(calories) kcal, \(protein)g protein. \(proteinGap)g protein left toward your \(memory.dailyProteinTarget)g target."
    }
}

struct JSONJournalPersistence: JournalPersisting {
    private let fileName = "just-enough-journal.json"

    func load() -> JournalSnapshot? {
        guard let url = fileURL(), FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.journal.decode(JournalSnapshot.self, from: data)
        } catch {
            return nil
        }
    }

    func save(_ snapshot: JournalSnapshot) {
        guard let url = fileURL() else { return }
        do {
            let data = try JSONEncoder.journal.encode(snapshot)
            try data.write(to: url, options: [.atomic])
        } catch {
            assertionFailure("Failed to save journal: \(error)")
        }
    }

    private func fileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }
}

private extension JSONEncoder {
    static var journal: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var journal: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
