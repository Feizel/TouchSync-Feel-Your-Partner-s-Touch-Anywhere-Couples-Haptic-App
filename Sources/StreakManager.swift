import Foundation
import CloudKit

@MainActor
class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var freezeTokens: Int = 0
    @Published var lastPerfectDay: Date?
    @Published var streakMilestones: [StreakMilestone] = []
    
    private let userDefaults = UserDefaults.standard
    private let calendar = Calendar.current
    
    init() {
        loadStreakData()
    }
    
    func checkDailyStreak(isPerfectDay: Bool) {
        let today = calendar.startOfDay(for: Date())
        let lastPerfectDayStart = lastPerfectDay.map { calendar.startOfDay(for: $0) }
        
        if isPerfectDay {
            if let lastDay = lastPerfectDayStart {
                let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
                
                if daysBetween == 1 {
                    // Consecutive day - continue streak
                    currentStreak += 1
                    lastPerfectDay = Date()
                } else if daysBetween > 1 {
                    // Gap in streak - check for freeze token usage
                    if freezeTokens > 0 && daysBetween == 2 {
                        // Use freeze token for 1-day gap
                        freezeTokens -= 1
                        currentStreak += 1
                        lastPerfectDay = Date()
                    } else {
                        // Reset streak
                        currentStreak = 1
                        lastPerfectDay = Date()
                    }
                }
                // If daysBetween == 0, it's the same day - no change
            } else {
                // First perfect day
                currentStreak = 1
                lastPerfectDay = Date()
            }
            
            checkStreakMilestones()
            saveStreakData()
        }
    }
    
    private func checkStreakMilestones() {
        let milestones = [
            StreakMilestone(days: 7, badge: "Bronze Heart", reward: "1 Freeze Token", icon: "🥉"),
            StreakMilestone(days: 30, badge: "Silver Heart", reward: "Custom Gesture Slot", icon: "🥈"),
            StreakMilestone(days: 100, badge: "Gold Heart", reward: "Advanced Patterns", icon: "🥇"),
            StreakMilestone(days: 365, badge: "Diamond Heart", reward: "Premium 50% Off", icon: "💎")
        ]
        
        for milestone in milestones {
            if currentStreak >= milestone.days && !streakMilestones.contains(where: { $0.days == milestone.days }) {
                streakMilestones.append(milestone)
                
                // Award freeze token for 7-day milestone
                if milestone.days == 7 {
                    freezeTokens += 1
                }
                
                // Notify UI of milestone achievement
                NotificationCenter.default.post(
                    name: .streakMilestoneAchieved,
                    object: milestone
                )
            }
        }
    }
    
    private func loadStreakData() {
        currentStreak = userDefaults.integer(forKey: "currentStreak")
        freezeTokens = userDefaults.integer(forKey: "freezeTokens")
        lastPerfectDay = userDefaults.object(forKey: "lastPerfectDay") as? Date
        
        if let milestonesData = userDefaults.data(forKey: "streakMilestones"),
           let milestones = try? JSONDecoder().decode([StreakMilestone].self, from: milestonesData) {
            streakMilestones = milestones
        }
    }
    
    private func saveStreakData() {
        userDefaults.set(currentStreak, forKey: "currentStreak")
        userDefaults.set(freezeTokens, forKey: "freezeTokens")
        userDefaults.set(lastPerfectDay, forKey: "lastPerfectDay")
        
        if let milestonesData = try? JSONEncoder().encode(streakMilestones) {
            userDefaults.set(milestonesData, forKey: "streakMilestones")
        }
    }
    
    func getStreakMessage() -> String {
        switch currentStreak {
        case 0:
            return "Start your streak today!"
        case 1:
            return "Great start! Keep it up!"
        case 2...6:
            return "Building momentum! \(7 - currentStreak) days to Bronze Heart"
        case 7...29:
            return "Bronze achieved! \(30 - currentStreak) days to Silver Heart"
        case 30...99:
            return "Silver achieved! \(100 - currentStreak) days to Gold Heart"
        case 100...364:
            return "Gold achieved! \(365 - currentStreak) days to Diamond Heart"
        default:
            return "Diamond Heart achieved! You're unstoppable!"
        }
    }
}

struct StreakMilestone: Codable, Identifiable {
    let id = UUID()
    let days: Int
    let badge: String
    let reward: String
    let icon: String
    
    private enum CodingKeys: String, CodingKey {
        case days, badge, reward, icon
    }
}

extension Notification.Name {
    static let streakMilestoneAchieved = Notification.Name("streakMilestoneAchieved")
}