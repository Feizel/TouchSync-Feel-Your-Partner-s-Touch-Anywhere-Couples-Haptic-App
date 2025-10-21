import SwiftUI

struct PerfectDayCelebrationView: View {
    @Binding var isPresented: Bool
    let xpEarned: Int
    
    @State private var showContent = false
    @State private var showHearts = false
    @State private var showXP = false
    @State private var showButton = false
    @State private var heartsScale: CGFloat = 0.5
    @State private var confettiOffset: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Background
            RadialGradient(
                colors: [
                    Color.touchSyncAmber.opacity(0.8),
                    Color.touchSyncCrimson.opacity(0.6),
                    Color.touchSyncCharcoal
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Confetti
            if showContent {
                ForEach(0..<20, id: \.self) { index in
                    Text(["💕", "💖", "💗", "💝", "✨"].randomElement() ?? "💕")
                        .font(.title)
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: confettiOffset + CGFloat(index * 50)
                        )
                        .opacity(showContent ? 1 : 0)
                }
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Perfect Day Icon
                if showContent {
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                }
                
                // Heart Characters Embracing
                if showHearts {
                    HStack(spacing: -20) {
                        HeartCharacter(
                            color: .touchSyncCrimson,
                            isUser: true,
                            isActive: true,
                            customization: HeartCustomization()
                        )
                        .scaleEffect(heartsScale)
                        .rotationEffect(.degrees(15))
                        
                        HeartCharacter(
                            color: .touchSyncRoseGold,
                            isUser: false,
                            isActive: true,
                            customization: HeartCustomization()
                        )
                        .scaleEffect(heartsScale)
                        .rotationEffect(.degrees(-15))
                    }
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: heartsScale)
                }
                
                // Text
                if showContent {
                    VStack(spacing: 12) {
                        Text("Perfect Day!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your bond is unbreakable today! 💝")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Text("All goals completed")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: showContent)
                }
                
                // XP Earned
                if showXP {
                    HStack {
                        Text("⭐")
                            .font(.title2)
                        Text("+\(xpEarned) XP")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .scaleEffect(showXP ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.0), value: showXP)
                }
                
                Spacer()
                
                // Continue Button
                if showButton {
                    Button("Continue") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.touchSyncCrimson)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .opacity(showButton ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(2.0), value: showButton)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startCelebrationSequence()
        }
    }
    
    private func startCelebrationSequence() {
        // Play haptic celebration
        HapticsManager.shared.playGesture(.heartTrace)
        
        // Animation sequence
        withAnimation(.easeInOut(duration: 0.5)) {
            showContent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showHearts = true
                heartsScale = 1.2
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 3.0)) {
                confettiOffset = 800
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showXP = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showButton = true
            }
        }
    }
}

#Preview {
    PerfectDayCelebrationView(isPresented: .constant(true), xpEarned: 50)
}