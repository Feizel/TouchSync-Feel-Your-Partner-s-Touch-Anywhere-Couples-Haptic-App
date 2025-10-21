import SwiftUI

struct HeartCharacter: View {
    let size: CGFloat
    let primaryColor: Color
    let secondaryColor: Color
    let isAnimating: Bool
    let accessory: HeartAccessory
    let expression: HeartExpression
    
    init(
        size: CGFloat = 100,
        primaryColor: Color = ColorPalette.crimson,
        secondaryColor: Color = ColorPalette.roseGold,
        isAnimating: Bool = false,
        accessory: HeartAccessory = .none,
        expression: HeartExpression = .happy
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.isAnimating = isAnimating
        self.accessory = accessory
        self.expression = expression
    }
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Heart shape with gradient
            HeartShape()
                .fill(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .scaleEffect(pulseScale)
                .shadow(color: primaryColor.opacity(glowOpacity), radius: size * 0.1)
            
            // Expression eyes
            HStack(spacing: size * 0.1) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(y: expression.eyeOffset)
                    .scaleEffect(expression.eyeScale)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(y: expression.eyeOffset)
                    .scaleEffect(expression.eyeScale)
            }
            .offset(y: -size * 0.1)
            
            // Accessory overlay
            if accessory != .none {
                Image(systemName: accessory.icon)
                    .font(.system(size: size * 0.2))
                    .foregroundColor(.white)
                    .offset(y: -size * 0.25)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            if isAnimating {
                startPulseAnimation()
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startPulseAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            glowOpacity = 0.6
        }
    }
    
    private func triggerActiveAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            pulseScale = 1.3
            glowOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pulseScale = 1.1
                glowOpacity = 0.6
            }
        }
    }
    
    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.0
            glowOpacity = 0.3
        }
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Heart shape using bezier curves
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.9))
        
        path.addCurve(
            to: CGPoint(x: width * 0.1, y: height * 0.3),
            control1: CGPoint(x: width * 0.5, y: height * 0.7),
            control2: CGPoint(x: width * 0.1, y: height * 0.5)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control1: CGPoint(x: width * 0.1, y: height * 0.1),
            control2: CGPoint(x: width * 0.3, y: height * 0.1)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.3),
            control1: CGPoint(x: width * 0.7, y: height * 0.1),
            control2: CGPoint(x: width * 0.9, y: height * 0.1)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.9),
            control1: CGPoint(x: width * 0.9, y: height * 0.5),
            control2: CGPoint(x: width * 0.5, y: height * 0.7)
        )
        
        return path
    }
}

#Preview {
    HStack(spacing: 40) {
        HeartCharacter(
            size: 100,
            primaryColor: ColorPalette.crimson,
            secondaryColor: ColorPalette.roseGold,
            isAnimating: true,
            accessory: .none,
            expression: .happy
        )
        
        HeartCharacter(
            size: 100,
            primaryColor: ColorPalette.deepPurple,
            secondaryColor: ColorPalette.roseGold,
            isAnimating: true,
            accessory: .crown,
            expression: .happy
        )
    }
    .padding()
    .background(Color.black)
}