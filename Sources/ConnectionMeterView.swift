import SwiftUI

struct ConnectionMeterView: View {
    @StateObject private var goalsManager = DailyGoalsManager()
    
    var body: some View {
        VStack(spacing: 12) {
            // Connection Strength Display
            VStack(spacing: 8) {
                HStack {
                    Text("Connection Strength:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(goalsManager.connectionPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(connectionColor)
                }
                
                // Progress Bar
                ProgressView(value: goalsManager.connectionPercentage / 100.0)
                    .progressViewStyle(ConnectionProgressStyle())
                    .frame(height: 8)
                
                // Connection Message
                Text(connectionMessage)
                    .font(.caption)
                    .foregroundColor(connectionColor)
                    .multilineTextAlignment(.center)
            }
            
            // Daily Goals
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goals")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 6) {
                    GoalProgressRow(
                        icon: "💌",
                        title: "Touch Goal",
                        progress: goalsManager.touchGoalProgress,
                        target: goalsManager.touchGoalTarget,
                        isComplete: goalsManager.isTouchGoalComplete
                    )
                    
                    GoalProgressRow(
                        icon: "💬",
                        title: "Response Goal",
                        progress: goalsManager.responseGoalProgress,
                        target: goalsManager.responseGoalTarget,
                        isComplete: goalsManager.isResponseGoalComplete
                    )
                    
                    GoalProgressRow(
                        icon: "⏰",
                        title: "Quality Goal",
                        progress: goalsManager.qualityGoalProgress,
                        target: goalsManager.qualityGoalTarget,
                        isComplete: goalsManager.isQualityGoalComplete
                    )
                }
            }
            
            // Perfect Day Banner
            if goalsManager.isPerfectDay {
                PerfectDayBanner()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var connectionColor: Color {
        switch goalsManager.connectionPercentage {
        case 0...25:
            return Color.blue
        case 26...50:
            return Color.purple
        case 51...75:
            return Color.pink
        case 76...99:
            return Color.red
        default:
            return Color(red: 255/255, green: 107/255, blue: 53/255)
        }
    }
    
    private var connectionMessage: String {
        switch goalsManager.connectionPercentage {
        case 0...25:
            return "Your bond needs attention 💙"
        case 26...50:
            return "You're connecting nicely 💜"
        case 51...75:
            return "Your bond is strong 💖"
        case 76...99:
            return "Your bond is very strong 💗"
        default:
            return "Your bond is unbreakable today! 💝"
        }
    }
}

struct ConnectionProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
            
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 139/255, green: 0/255, blue: 0/255),
                            Color(red: 183/255, green: 110/255, blue: 121/255),
                            Color(red: 255/255, green: 107/255, blue: 53/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(x: configuration.fractionCompleted ?? 0, y: 1, anchor: .leading)
        }
    }
}

struct GoalProgressRow: View {
    let icon: String
    let title: String
    let progress: Int
    let target: Int
    let isComplete: Bool
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(progress)/\(target)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .secondary)
                .font(.title3)
        }
        .opacity(isComplete ? 1.0 : 0.7)
    }
}

struct PerfectDayBanner: View {
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            Text("🎉")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Perfect Day!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("All goals complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("✨")
                .font(.title2)
                .offset(x: sparkleOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        sparkleOffset = 10
                    }
                }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 107/255, blue: 53/255).opacity(0.3),
                    Color(red: 183/255, green: 110/255, blue: 121/255).opacity(0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

@MainActor
class DailyGoalsManager: ObservableObject {
    @Published var touchGoalProgress: Int = 0
    @Published var responseGoalProgress: Int = 0
    @Published var qualityGoalProgress: Int = 0
    @Published var showPerfectDayCelebration = false
    
    let touchGoalTarget: Int = 5
    let responseGoalTarget: Int = 3
    let qualityGoalTarget: Int = 60 // seconds
    
    private let streakManager = StreakManager()
    private let levelingManager = LevelingManager()
    
    var isTouchGoalComplete: Bool {
        touchGoalProgress >= touchGoalTarget
    }
    
    var isResponseGoalComplete: Bool {
        responseGoalProgress >= responseGoalTarget
    }
    
    var isQualityGoalComplete: Bool {
        qualityGoalProgress >= qualityGoalTarget
    }
    
    var isPerfectDay: Bool {
        let perfectDay = isTouchGoalComplete && isResponseGoalComplete && isQualityGoalComplete
        
        // Check if this is a new perfect day
        if perfectDay && !UserDefaults.standard.bool(forKey: "perfectDayToday") {
            UserDefaults.standard.set(true, forKey: "perfectDayToday")
            
            // Award XP and update streak
            levelingManager.addXP(XPAction.perfectDay.xpValue, for: .perfectDay)
            streakManager.checkDailyStreak(isPerfectDay: true)
            
            // Show celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showPerfectDayCelebration = true
            }
        }
        
        return perfectDay
    }
    
    var connectionPercentage: Double {
        let completedGoals = [isTouchGoalComplete, isResponseGoalComplete, isQualityGoalComplete].filter { $0 }.count
        let partialProgress = (Double(touchGoalProgress) / Double(touchGoalTarget) +
                             Double(responseGoalProgress) / Double(responseGoalTarget) +
                             Double(qualityGoalProgress) / Double(qualityGoalTarget)) / 3.0
        
        return min(100.0, (Double(completedGoals) * 33.33) + (partialProgress * 33.33))
    }
    
    func incrementTouchGoal() {
        if touchGoalProgress < touchGoalTarget {
            touchGoalProgress += 1
            levelingManager.addXP(XPAction.sendTouch.xpValue, for: .sendTouch)
        }
    }
    
    func incrementResponseGoal() {
        if responseGoalProgress < responseGoalTarget {
            responseGoalProgress += 1
            levelingManager.addXP(XPAction.respondToTouch.xpValue, for: .respondToTouch)
        }
    }
    
    func updateQualityGoal(seconds: Int) {
        let oldProgress = qualityGoalProgress
        qualityGoalProgress = min(qualityGoalTarget, seconds)
        
        if oldProgress < qualityGoalTarget && qualityGoalProgress >= qualityGoalTarget {
            levelingManager.addXP(XPAction.qualityTouch.xpValue, for: .qualityTouch)
        }
    }
    
    func resetDailyGoals() {
        touchGoalProgress = 0
        responseGoalProgress = 0
        qualityGoalProgress = 0
        UserDefaults.standard.set(false, forKey: "perfectDayToday")
    }
}

#Preview {
    ConnectionMeterView()
        .padding()
        .background(Color.black)
}