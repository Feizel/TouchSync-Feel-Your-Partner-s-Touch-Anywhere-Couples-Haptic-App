import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case emotionalHook = 1
    case firstTouch = 2
    case heartIntro = 3
    case tutorial = 4
    case goals = 5
    
    var title: String {
        switch self {
        case .welcome: return "Welcome to TouchSync"
        case .emotionalHook: return "Feel Them From Anywhere"
        case .firstTouch: return "Your First Touch"
        case .heartIntro: return "Meet Your Hearts"
        case .tutorial: return "How It Works"
        case .goals: return "Set Your Goals"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "The intimate connection app for couples"
        case .emotionalHook: return "Distance means nothing when love means everything"
        case .firstTouch: return "Experience the magic of haptic touch"
        case .heartIntro: return "Your relationship, visualized"
        case .tutorial: return "Send touches, build streaks, grow together"
        case .goals: return "What matters most to your relationship?"
        }
    }
}

@MainActor
class OnboardingManager: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isCompleted = false
    @Published var selectedGoals: Set<RelationshipGoal> = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        isCompleted = userDefaults.bool(forKey: "onboardingCompleted")
    }
    
    func nextStep() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    func completeOnboarding() {
        isCompleted = true
        userDefaults.set(true, forKey: "onboardingCompleted")
        
        // Save selected goals
        let goalIds = selectedGoals.map { $0.id }
        userDefaults.set(goalIds, forKey: "selectedGoals")
    }
    
    func skipToEnd() {
        completeOnboarding()
    }
}

enum RelationshipGoal: String, CaseIterable, Identifiable {
    case dailyConnection = "daily_connection"
    case intimacy = "intimacy"
    case communication = "communication"
    case playfulness = "playfulness"
    case support = "support"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dailyConnection: return "Daily Connection"
        case .intimacy: return "Physical Intimacy"
        case .communication: return "Better Communication"
        case .playfulness: return "More Playfulness"
        case .support: return "Emotional Support"
        }
    }
    
    var description: String {
        switch self {
        case .dailyConnection: return "Stay connected every day"
        case .intimacy: return "Feel closer physically"
        case .communication: return "Express feelings better"
        case .playfulness: return "Have more fun together"
        case .support: return "Be there for each other"
        }
    }
    
    var icon: String {
        switch self {
        case .dailyConnection: return "heart.circle.fill"
        case .intimacy: return "hands.sparkles.fill"
        case .communication: return "message.circle.fill"
        case .playfulness: return "face.smiling.fill"
        case .support: return "hand.raised.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dailyConnection: return ColorPalette.crimson
        case .intimacy: return ColorPalette.roseGold
        case .communication: return ColorPalette.amber
        case .playfulness: return ColorPalette.deepPurple
        case .support: return ColorPalette.crimson
        }
    }
}