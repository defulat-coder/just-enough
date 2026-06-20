import Foundation

struct MacroProfile: Codable, Hashable {
    var protein: Int
    var carbs: Int
    var fat: Int

    var shortText: String {
        "蛋\(protein) 碳\(carbs) 脂\(fat)"
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

    var calorieBalanceText: String {
        let balance = targetCalories - calories
        if balance >= 0 {
            return "还差 \(balance.formatted()) 千卡"
        }
        return "超出 \(abs(balance).formatted()) 千卡"
    }

    var eyebrow: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    var pagerTitle: String {
        title
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
        trainingContext: "力量训练优先，高蛋白，记录方式保持轻松。",
        commonFoods: ["拿铁咖啡", "蓝莓松饼", "清爽绿叶碗", "香煎三文鱼餐", "希腊酸奶"]
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
                title: "今天",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "蓝莓松饼", serving: "松软松饼，枫糖浆", calories: 520, macros: MacroProfile(protein: 10, carbs: 68, fat: 18), image: "pancakes", hero: "pancakes-hero", date: today),
                    makeEntry(name: "拿铁咖啡", serving: "冰饮，燕麦奶", calories: 180, macros: MacroProfile(protein: 6, carbs: 22, fat: 6), image: "latte", hero: "latte", date: today),
                    makeEntry(name: "清爽绿叶碗", serving: "亮绿蔬菜，牛油果，鹰嘴豆", calories: 340, macros: MacroProfile(protein: 15, carbs: 31, fat: 18), image: "greens", hero: "greens", date: today),
                    makeEntry(name: "香煎三文鱼餐", serving: "三文鱼，米饭，加量蔬菜", calories: 620, macros: MacroProfile(protein: 41, carbs: 43, fat: 30), image: "salmon", hero: "salmon", date: today)
                ],
                messages: [
                    AgentMessage(role: .user, text: "松饼、拿铁、绿叶碗、三文鱼", createdAt: today),
                    AgentMessage(role: .agent, text: "已记录一组适合训练日的均衡餐：1,660 千卡，72g 蛋白。", createdAt: today)
                ],
                summary: "今天开得很稳；晚餐补上了蛋白，也有足够颜色。"
            ),
            FoodDay(
                id: "2026-06-18",
                date: yesterday,
                title: "昨天",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "拿铁咖啡", serving: "冰饮，燕麦奶", calories: 160, macros: MacroProfile(protein: 3, carbs: 22, fat: 6), image: "latte", hero: "latte", date: yesterday),
                    makeEntry(name: "清爽绿叶碗", serving: "加鹰嘴豆", calories: 430, macros: MacroProfile(protein: 15, carbs: 38, fat: 25), image: "greens", hero: "greens", date: yesterday),
                    makeEntry(name: "香煎三文鱼餐", serving: "加量蔬菜", calories: 560, macros: MacroProfile(protein: 41, carbs: 24, fat: 30), image: "salmon", hero: "salmon", date: yesterday)
                ],
                messages: [
                    AgentMessage(role: .user, text: "冰拿铁、绿叶碗和三文鱼", createdAt: yesterday),
                    AgentMessage(role: .agent, text: "这一组很轻快：咖啡提神，蔬菜有脆感，三文鱼收尾。", createdAt: yesterday)
                ],
                summary: "这一组很轻快：咖啡提神，蔬菜有脆感，三文鱼收尾。"
            ),
            FoodDay(
                id: "2026-06-17",
                date: wednesday,
                title: "周三",
                targetCalories: 2_800,
                entries: [
                    makeEntry(name: "蓝莓松饼", serving: "小份松饼", calories: 360, macros: MacroProfile(protein: 8, carbs: 50, fat: 12), image: "pancakes", hero: "pancakes-hero", date: wednesday),
                    makeEntry(name: "清爽绿叶碗", serving: "轻量绿叶菜", calories: 310, macros: MacroProfile(protein: 10, carbs: 26, fat: 18), image: "greens", hero: "greens", date: wednesday),
                    makeEntry(name: "拿铁咖啡", serving: "小杯燕麦拿铁", calories: 120, macros: MacroProfile(protein: 3, carbs: 10, fat: 6), image: "latte", hero: "latte", date: wednesday)
                ],
                messages: [
                    AgentMessage(role: .user, text: "松饼、绿叶菜和咖啡", createdAt: wednesday),
                    AgentMessage(role: .agent, text: "咖啡带来安定感，绿叶菜轻轻重置。柔和、简单、刚刚好。", createdAt: wednesday)
                ],
                summary: "咖啡带来安定感，绿叶菜轻轻重置。柔和、简单、刚刚好。"
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
                source: "本地营养库",
                rationale: "根据你的常吃食物和稳定的本地营养样本估算。"
            ),
            visual: FoodVisual(imageName: image, heroImageName: hero, backgroundImageName: image == "pancakes" ? "warm-detail-bg" : "camera-bg"),
            loggedAt: date
        )
    }
}
