import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @State private var showingFirstTouch = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [ColorPalette.deepPurple.opacity(0.3), ColorPalette.crimson.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $onboardingManager.currentStep) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    onboardingStepView(for: step)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: onboardingManager.currentStep)
        }
        .overlay(alignment: .bottom) {
            onboardingControls
        }
        .fullScreenCover(isPresented: $showingFirstTouch) {
            FirstTouchExperienceView()
        }
    }
    
    @ViewBuilder
    private func onboardingStepView(for step: OnboardingStep) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            switch step {
            case .welcome:
                WelcomeStepView()
            case .emotionalHook:
                EmotionalHookStepView()
            case .firstTouch:
                FirstTouchStepView(showingFirstTouch: $showingFirstTouch)
            case .heartIntro:
                HeartIntroStepView()
            case .tutorial:
                TutorialStepView()
            case .goals:
                GoalsStepView(selectedGoals: $onboardingManager.selectedGoals)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var onboardingControls: some View {
        VStack(spacing: 16) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= onboardingManager.currentStep.rawValue ? 
                              ColorPalette.amber : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Navigation buttons
            HStack {
                if onboardingManager.currentStep != .welcome {
                    Button("Back") {
                        onboardingManager.previousStep()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button("Skip") {
                    onboardingManager.skipToEnd()
                }
                .foregroundColor(.white.opacity(0.7))
                
                Button(onboardingManager.currentStep == .goals ? "Get Started" : "Next") {
                    onboardingManager.nextStep()
                }
                .font(.body.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(ColorPalette.crimson, in: Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

// MARK: - Individual Step Views

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            // App icon or heart animation
            HeartCharacter(
                size: 120,
                primaryColor: ColorPalette.crimson,
                secondaryColor: ColorPalette.roseGold,
                isAnimating: true
            )
            
            VStack(spacing: 12) {
                Text("Welcome to TouchSync")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("The intimate connection app for couples")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct EmotionalHookStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Two hearts with connection
            HStack(spacing: 40) {
                HeartCharacter(
                    size: 80,
                    primaryColor: ColorPalette.crimson,
                    secondaryColor: ColorPalette.roseGold,
                    isAnimating: true
                )
                
                HeartCharacter(
                    size: 80,
                    primaryColor: ColorPalette.deepPurple,
                    secondaryColor: ColorPalette.roseGold,
                    isAnimating: true
                )
            }
            
            VStack(spacing: 16) {
                Text("Feel Them From Anywhere")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Distance means nothing when love means everything. Send real touches that your partner can actually feel.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
    }
}

struct FirstTouchStepView: View {
    @Binding var showingFirstTouch: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Interactive touch demo
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 40))
                        .foregroundColor(ColorPalette.amber)
                    
                    Text("Tap to Feel")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                HapticsManager.shared.playGesture(HapticsManager.shared.presetGestures[0])
                showingFirstTouch = true
            }
            
            VStack(spacing: 16) {
                Text("Your First Touch")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Tap above to experience the magic of haptic touch. This is how your partner will feel your love.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct HeartIntroStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Heart pair with connection line
            HeartCharactersPairView()
                .scaleEffect(0.8)
            
            VStack(spacing: 16) {
                Text("Meet Your Hearts")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("These hearts represent you and your partner. Watch them grow and change as your relationship deepens.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct TutorialStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Feature highlights
            VStack(spacing: 16) {
                FeatureHighlight(
                    icon: "hand.draw.fill",
                    title: "Send Touches",
                    description: "Draw on the canvas or use preset gestures"
                )
                
                FeatureHighlight(
                    icon: "flame.fill",
                    title: "Build Streaks",
                    description: "Connect daily to grow your streak"
                )
                
                FeatureHighlight(
                    icon: "heart.fill",
                    title: "Grow Together",
                    description: "Level up your relationship with XP"
                )
            }
            
            VStack(spacing: 16) {
                Text("How It Works")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Send touches, build streaks, and watch your relationship grow stronger every day.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorPalette.amber)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct GoalsStepView: View {
    @Binding var selectedGoals: Set<RelationshipGoal>
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Set Your Goals")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("What matters most to your relationship?")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(RelationshipGoal.allCases) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
        }
    }
}

struct GoalCard: View {
    let goal: RelationshipGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : goal.color)
                
                Text(goal.title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? goal.color : .ultraThinMaterial)
            )
        }
    }
}