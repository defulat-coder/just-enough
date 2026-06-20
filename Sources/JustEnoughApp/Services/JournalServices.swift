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

        if normalized.contains("pancake") || normalized.contains("松饼") {
            known = (520, MacroProfile(protein: 10, carbs: 68, fat: 18), "参考早餐历史中的松饼份量估算。")
        } else if normalized.contains("latte") || normalized.contains("coffee") || normalized.contains("拿铁") || normalized.contains("咖啡") {
            known = (180, MacroProfile(protein: 6, carbs: 22, fat: 6), "按你的燕麦奶拿铁偏好估算。")
        } else if normalized.contains("yogurt") || normalized.contains("酸奶") {
            known = (210, MacroProfile(protein: 24, carbs: 18, fat: 4), "参考高蛋白酸奶加餐历史估算。")
        } else if normalized.contains("egg") || normalized.contains("鸡蛋") || normalized.contains("蛋") {
            known = (220, MacroProfile(protein: 18, carbs: 2, fat: 15), "按三枚鸡蛋的常见份量估算。")
        } else if normalized.contains("chicken") || normalized.contains("鸡肉") {
            known = (540, MacroProfile(protein: 48, carbs: 45, fat: 14), "鸡肉米饭按力量训练日份量估算。")
        } else if normalized.contains("salmon") || normalized.contains("三文鱼") {
            known = (620, MacroProfile(protein: 41, carbs: 43, fat: 30), "三文鱼餐估算包含米饭和加量蔬菜。")
        } else if normalized.contains("avocado") || normalized.contains("salad") || normalized.contains("greens") || normalized.contains("牛油果") || normalized.contains("沙拉") || normalized.contains("绿叶") {
            known = (430, MacroProfile(protein: 15, carbs: 38, fat: 25), "根据绿叶菜、鸡蛋、牛油果和脆脆配料推断。")
        } else {
            known = (460, MacroProfile(protein: 24, carbs: 42, fat: 18), "根据当前热量目标和常见正餐份量兜底估算。")
        }

        return NutritionEstimate(
            calories: known.0,
            macros: known.1,
            confidence: normalized.contains("unknown") || normalized.contains("不确定") ? 0.55 : 0.84,
            source: "本地营养库",
            rationale: known.2
        )
    }
}

struct LocalFoodVisualProvider: FoodVisualProviding {
    func visual(for foodName: String) -> FoodVisual {
        let normalized = foodName.lowercased()
        if normalized.contains("pancake") || normalized.contains("松饼") {
            return FoodVisual(imageName: "pancakes", heroImageName: "pancakes-hero", backgroundImageName: "warm-detail-bg")
        }
        if normalized.contains("latte") || normalized.contains("coffee") || normalized.contains("拿铁") || normalized.contains("咖啡") {
            return FoodVisual(imageName: "latte", heroImageName: "latte", backgroundImageName: "warm-detail-bg")
        }
        if normalized.contains("salmon") || normalized.contains("三文鱼") {
            return FoodVisual(imageName: "salmon", heroImageName: "salmon", backgroundImageName: "camera-bg")
        }
        if normalized.contains("salad") || normalized.contains("greens") || normalized.contains("avocado") || normalized.contains("沙拉") || normalized.contains("绿叶") || normalized.contains("牛油果") {
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

        if normalized.contains("pancake") || normalized.contains("松饼") {
            append("蓝莓松饼", "松软松饼，枫糖浆")
        }
        if normalized.contains("latte") || normalized.contains("coffee") || normalized.contains("拿铁") || normalized.contains("咖啡") {
            append("拿铁咖啡", "冰饮，燕麦奶")
        }
        if normalized.contains("yogurt") || normalized.contains("酸奶") {
            append("希腊酸奶碗", "浆果，蜂蜜，高蛋白酸奶")
        }
        if normalized.contains("egg") || normalized.contains("鸡蛋") || normalized.contains("蛋") {
            append("嫩煎鸡蛋", "三枚鸡蛋，简单调味")
        }
        if normalized.contains("chicken") || normalized.contains("rice") || normalized.contains("鸡肉") || normalized.contains("米饭") {
            append("鸡肉米饭碗", "鸡肉，米饭，蔬菜")
        }
        if normalized.contains("salmon") || normalized.contains("三文鱼") {
            append("香煎三文鱼餐", "三文鱼，米饭，加量蔬菜")
        }
        if normalized.contains("salad") || normalized.contains("greens") || normalized.contains("avocado") || normalized.contains("沙拉") || normalized.contains("绿叶") || normalized.contains("牛油果") {
            append("牛油果花园沙拉", "鸡蛋、番茄、黄瓜和脆脆配料")
        }
        if drafts.isEmpty {
            append(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "均衡餐盘" : input, "智能体估算份量")
        }
        return drafts
    }

    func response(for input: String, entries: [FoodEntry], memory: UserNutritionMemory) -> String {
        let calories = entries.reduce(0) { $0 + $1.estimate.calories }
        let protein = entries.reduce(0) { $0 + $1.estimate.macros.protein }
        let names = entries.map(\.name).joined(separator: "、")
        let proteinGap = max(memory.dailyProteinTarget - protein, 0)
        return "已记录 \(names)。流式估算：\(calories) 千卡，\(protein)g 蛋白。距离 \(memory.dailyProteinTarget)g 蛋白目标还差 \(proteinGap)g。"
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
