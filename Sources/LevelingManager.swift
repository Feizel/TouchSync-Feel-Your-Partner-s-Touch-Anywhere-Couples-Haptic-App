import Foundation

@MainActor
class LevelingManager: ObservableObject {
    @Published var totalXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var currentTier: RelationshipTier = .newLove
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadLevelData()
        updateTier()
    }
    
    func addXP(_ amount: Int, for action: XPAction) {
        let oldLevel = currentLevel
        totalXP += amount
        
        // Calculate new level
        currentLevel = calculateLevel(from: totalXP)
        updateTier()
        
        // Check for level up
        if currentLevel > oldLevel {
            NotificationCenter.default.post(
                name: .levelUp,
                object: LevelUpInfo(
                    newLevel: currentLevel,
                    newTier: currentTier,
                    xpEarned: amount,
                    action: action
                )
            )
        }
        
        saveLevelData()
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        // XP required: Level 1 = 0, Level 2 = 100, Level 3 = 250, etc.
        // Formula: XP = level * 100 + (level-1) * 50
        var level = 1
        var requiredXP = 0
        
        while requiredXP <= xp {
            level += 1
            requiredXP += (level - 1) * 100 + (level - 2) * 50
        }
        
        return max(1, level - 1)
    }
    
    func xpForNextLevel() -> Int {
        let nextLevel = currentLevel + 1
        let nextLevelXP = (nextLevel - 1) * 100 + max(0, (nextLevel - 2)) * 50
        return nextLevelXP
    }
    
    func xpProgressToNextLevel() -> Double {
        let currentLevelXP = max(0, (currentLevel - 1) * 100 + max(0, (currentLevel - 2)) * 50)
        let nextLevelXP = xpForNextLevel()
        let progress = Double(totalXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return max(0, min(1, progress))
    }
    
    private func updateTier() {
        currentTier = RelationshipTier.fromLevel(currentLevel)
    }
    
    private func loadLevelData() {
        totalXP = userDefaults.integer(forKey: "totalXP")
        currentLevel = max(1, userDefaults.integer(forKey: "currentLevel"))
        if currentLevel == 0 { currentLevel = 1 }
    }
    
    private func saveLevelData() {
        userDefaults.set(totalXP, forKey: "totalXP")
        userDefaults.set(currentLevel, forKey: "currentLevel")
    }
}

enum XPAction: String, CaseIterable {
    case sendTouch = "Send touch"
    case respondToTouch = "Respond to touch within 2h"
    case perfectDay = "Close all goals (Perfect Day)"
    case qualityTouch = "30+ second quality touch"
    case streakMilestone = "7-day streak milestone"
    
    var xpValue: Int {
        switch self {
        case .sendTouch: return 10
        case .respondToTouch: return 15
        case .perfectDay: return 50
        case .qualityTouch: return 25
        case .streakMilestone: return 100
        }
    }
}

enum RelationshipTier: String, CaseIterable {
    case newLove = "New Love"
    case deepeningBond = "Deepening Bond"
    case strongConnection = "Strong Connection"
    case soulmates = "Soulmates"
    
    var levelRange: ClosedRange<Int> {
        switch self {
        case .newLove: return 1...10
        case .deepeningBond: return 11...25
        case .strongConnection: return 26...50
        case .soulmates: return 51...100
        }
    }
    
    var icon: String {
        switch self {
        case .newLove: return "💕"
        case .deepeningBond: return "💖"
        case .strongConnection: return "💗"
        case .soulmates: return "💝"
        }
    }
    
    var color: String {
        switch self {
        case .newLove: return "#FF6B35"
        case .deepeningBond: return "#B76E79"
        case .strongConnection: return "#8B0000"
        case .soulmates: return "#4A0E4E"
        }
    }
    
    var unlocks: [String] {
        switch self {
        case .newLove:
            return ["Basic 5 gestures", "Touch history 7 days"]
        case .deepeningBond:
            return ["Custom gesture recorder", "Hairstyle customization", "Voice questions"]
        case .strongConnection:
            return ["Nature haptic patterns", "Accessories", "Unlimited history"]
        case .soulmates:
            return ["All features", "Special anniversary animations", "Premium insights"]
        }
    }
    
    static func fromLevel(_ level: Int) -> RelationshipTier {
        for tier in RelationshipTier.allCases {
            if tier.levelRange.contains(level) {
                return tier
            }
        }
        return .soulmates // Fallback for levels > 100
    }
}

struct LevelUpInfo {
    let newLevel: Int
    let newTier: RelationshipTier
    let xpEarned: Int
    let action: XPAction
}

extension Notification.Name {
    static let levelUp = Notification.Name("levelUp")
}