import Foundation

struct MacroProfile: Codable, Hashable {
    var protein: Int
    var carbs: Int
    var fat: Int

    var shortText: String {
        "\(protein) P  \(carbs) C  \(fat) F"
    }
}

struct NutritionEstimate: Codable, Hashable {
    var calories: Int
    var macros: MacroProfile
    var confidence: Double
    var source: String
    var rationale: String
}

struct FoodVisual: Codable, Hashable {
    var imageName: String
    var heroImageName: String
    var backgroundImageName: String
}

struct FoodEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var servingDescription: String
    var estimate: NutritionEstimate
    var visual: FoodVisual
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        servingDescription: String,
        estimate: NutritionEstimate,
        visual: FoodVisual,
        loggedAt: Date
    ) {
        self.id = id
        self.name = name
        self.servingDescription = servingDescription
        self.estimate = estimate
        self.visual = visual
        self.loggedAt = loggedAt
    }
}

enum MessageRole: String, Codable, Hashable {
    case user
    case agent
}

struct AgentMessage: Identifiable, Codable, Hashable {
    var id: UUID
    var role: MessageRole
    var text: String
    var createdAt: Date
    var relatedEntryIDs: [UUID]

    init(
        id: UUID = UUID(),
        role: MessageRole,
        text: String,
        createdAt: Date,
        relatedEntryIDs: [UUID] = []
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.relatedEntryIDs = relatedEntryIDs
    }
}

struct FoodDay: Identifiable, Codable, Hashable {
    var id: String
    var date: Date
    var title: String
    var targetCalories: Int
    var entries: [FoodEntry]
    var messages: [AgentMessage]
    var summary: String

    var calories: Int {
        entries.reduce(0) { $0 + $1.estimate.calories }
    }

    var macros: MacroProfile {
        entries.reduce(MacroProfile(protein: 0, carbs: 0, fat: 0)) { partial, entry in
            MacroProfile(
                protein: partial.protein + entry.estimate.macros.protein,
                carbs: partial.carbs + entry.estimate.macros.carbs,
                fat: partial.fat + entry.estimate.macros.fat
            )
        }
    }

    var progress: Double {
        min(Double(calories) / Double(targetCalories), 1)
    }

    var eyebrow: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date).uppercased()
    }

    var pagerTitle: String {
        switch title {
        case "Yesterday":
            return "Yday"
        case "Wednesday":
            return "Wed"
        default:
            return title
        }
    }
}

struct UserNutritionMemory: Codable, Hashable {
    var dailyCalorieTarget: Int
    var dailyProteinTarget: Int
    var trainingContext: String
    var commonFoods: [String]

    static let initial = UserNutritionMemory(
        dailyCalorieTarget: 2_800,
        dailyProteinTarget: 150,
        trainingContext: "Lifting-focused nutrition, high protein, calm tracking.",
        commonFoods: ["Cafe Latte", "Blueberry Pancakes", "Crisp Greens Bowl", "Grilled Salmon Plate"]
    )
}

struct JournalSnapshot: Codable, Hashable {
    var memory: UserNutritionMemory
    var days: [FoodDay]
}

struct AgentMealDraft: Hashable {
    var name: String
    var servingDescription: String
    var loggedAt: Date
}

struct AgentRunResult: Hashable {
    var userMessage: AgentMessage
    var agentMessage: AgentMessage
    var entries: [FoodEntry]
}

enum JournalFixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    static let today = calendar.date(from: DateComponents(year: 2026, month: 6, day: 19, hour: 19, minute: 30)) ?? Date()
    static let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? Date()
    static let wednesday = calendar.date(byAdding: .day, value: -2, to: today) ?? Date()

    static let initialSnapshot = JournalSnapshot(
        memory: .initial,
        days: [
            FoodDay(
                id: "2026-06-19",
                date: today,
                title: "Today",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "Blueberry Pancakes", serving: "fluffy stack, maple syrup", calories: 520, macros: MacroProfile(protein: 10, carbs: 68, fat: 18), image: "pancakes", hero: "pancakes-hero", date: today),
                    makeEntry(name: "Cafe Latte", serving: "iced, oat milk", calories: 180, macros: MacroProfile(protein: 6, carbs: 22, fat: 6), image: "latte", hero: "latte", date: today),
                    makeEntry(name: "Crisp Greens Bowl", serving: "bright greens, avocado, chickpeas", calories: 340, macros: MacroProfile(protein: 15, carbs: 31, fat: 18), image: "greens", hero: "greens", date: today),
                    makeEntry(name: "Grilled Salmon Plate", serving: "salmon, rice, extra vegetables", calories: 620, macros: MacroProfile(protein: 41, carbs: 43, fat: 30), image: "salmon", hero: "salmon", date: today)
                ],
                messages: [
                    AgentMessage(role: .user, text: "pancakes, latte, greens bowl, salmon", createdAt: today),
                    AgentMessage(role: .agent, text: "Logged a balanced training-day lineup. You are at 1,660 kcal with 72g protein.", createdAt: today)
                ],
                summary: "Lovely landing for the day; dinner brought the protein and the color."
            ),
            FoodDay(
                id: "2026-06-18",
                date: yesterday,
                title: "Yesterday",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "Cafe Latte", serving: "iced, oat milk", calories: 160, macros: MacroProfile(protein: 3, carbs: 22, fat: 6), image: "latte", hero: "latte", date: yesterday),
                    makeEntry(name: "Crisp Greens Bowl", serving: "with chickpeas", calories: 430, macros: MacroProfile(protein: 15, carbs: 38, fat: 25), image: "greens", hero: "greens", date: yesterday),
                    makeEntry(name: "Grilled Salmon Plate", serving: "extra vegetables", calories: 560, macros: MacroProfile(protein: 41, carbs: 24, fat: 30), image: "salmon", hero: "salmon", date: yesterday)
                ],
                messages: [
                    AgentMessage(role: .user, text: "iced latte, greens bowl, and salmon", createdAt: yesterday),
                    AgentMessage(role: .agent, text: "A breezy little lineup: coffee sparkle, greens crunch, salmon finish.", createdAt: yesterday)
                ],
                summary: "A breezy little lineup: coffee sparkle, greens crunch, salmon finish."
            ),
            FoodDay(
                id: "2026-06-17",
                date: wednesday,
                title: "Wednesday",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "Blueberry Pancakes", serving: "smaller stack", calories: 360, macros: MacroProfile(protein: 8, carbs: 50, fat: 12), image: "pancakes", hero: "pancakes-hero", date: wednesday),
                    makeEntry(name: "Crisp Greens Bowl", serving: "light greens", calories: 310, macros: MacroProfile(protein: 10, carbs: 26, fat: 18), image: "greens", hero: "greens", date: wednesday),
                    makeEntry(name: "Cafe Latte", serving: "small oat latte", calories: 120, macros: MacroProfile(protein: 3, carbs: 10, fat: 6), image: "latte", hero: "latte", date: wednesday)
                ],
                messages: [
                    AgentMessage(role: .user, text: "pancakes, greens, and coffee", createdAt: wednesday),
                    AgentMessage(role: .agent, text: "Cafe comfort with a small green reset. Soft, simple, enough.", createdAt: wednesday)
                ],
                summary: "Cafe comfort with a small green reset. Soft, simple, enough."
            )
        ]
    )

    static func makeEntry(
        name: String,
        serving: String,
        calories: Int,
        macros: MacroProfile,
        image: String,
        hero: String,
        date: Date
    ) -> FoodEntry {
        FoodEntry(
            name: name,
            servingDescription: serving,
            estimate: NutritionEstimate(
                calories: calories,
                macros: macros,
                confidence: 0.86,
                source: "USDA-style local nutrition",
                rationale: "Estimated from the user's common foods and stable local nutrition fixtures."
            ),
            visual: FoodVisual(imageName: image, heroImageName: hero, backgroundImageName: image == "pancakes" ? "warm-detail-bg" : "camera-bg"),
            loggedAt: date
        )
    }
}
