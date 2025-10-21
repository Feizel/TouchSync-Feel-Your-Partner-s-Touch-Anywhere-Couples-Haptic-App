import SwiftUI

struct FirstTouchExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentGesture = 0
    @State private var showingHeartReaction = false
    
    private let demoGestures = [
        ("Squeeze Hand", "hand.raised.fill", "A gentle squeeze to say 'I'm here'"),
        ("Forehead Kiss", "lips.fill", "A tender kiss on your forehead"),
        ("Warm Hug", "figure.2.arms.open", "A loving embrace from afar"),
        ("Heart Trace", "heart.fill", "Draw a heart with your finger")
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [ColorPalette.deepPurple.opacity(0.4), ColorPalette.crimson.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("Feel the Magic")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("Experience how your partner will feel your touch")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Heart character with reaction
                ZStack {
                    HeartCharacter(
                        size: 120,
                        primaryColor: ColorPalette.crimson,
                        secondaryColor: ColorPalette.roseGold,
                        isAnimating: showingHeartReaction
                    )
                    
                    if showingHeartReaction {
                        // Reaction particles
                        ForEach(0..<6, id: \.self) { i in
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(ColorPalette.amber)
                                .offset(
                                    x: cos(Double(i) * .pi / 3) * 40,
                                    y: sin(Double(i) * .pi / 3) * 40
                                )
                                .opacity(showingHeartReaction ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 1.5).delay(Double(i) * 0.1),
                                    value: showingHeartReaction
                                )
                        }
                    }
                }
                .frame(height: 160)
                
                // Current gesture info
                VStack(spacing: 16) {
                    let gesture = demoGestures[currentGesture]
                    
                    Image(systemName: gesture.1)
                        .font(.system(size: 32))
                        .foregroundColor(ColorPalette.amber)
                    
                    Text(gesture.0)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text(gesture.2)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Try it button
                Button(action: tryCurrentGesture) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                        Text("Feel This Touch")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.crimson, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                
                // Navigation
                HStack {
                    Button("Previous") {
                        withAnimation {
                            currentGesture = max(0, currentGesture - 1)
                        }
                    }
                    .disabled(currentGesture == 0)
                    .foregroundColor(currentGesture == 0 ? .white.opacity(0.3) : .white.opacity(0.7))
                    
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<demoGestures.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentGesture ? ColorPalette.amber : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    if currentGesture < demoGestures.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentGesture = min(demoGestures.count - 1, currentGesture + 1)
                            }
                        }
                        .foregroundColor(.white.opacity(0.7))
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(ColorPalette.amber)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 60)
            .padding(.trailing, 24)
        }
    }
    
    private func tryCurrentGesture() {
        // Play haptic feedback
        let hapticsManager = HapticsManager.shared
        if currentGesture < hapticsManager.presetGestures.count {
            hapticsManager.playGesture(hapticsManager.presetGestures[currentGesture])
        }
        
        // Show heart reaction
        withAnimation(.easeInOut(duration: 0.3)) {
            showingHeartReaction = true
        }
        
        // Reset reaction after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingHeartReaction = false
            }
        }
    }
}