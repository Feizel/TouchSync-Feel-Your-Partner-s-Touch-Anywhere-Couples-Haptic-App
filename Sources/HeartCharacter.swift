import SwiftUI

struct HeartCharacter: View {
    let color: Color
    let isUser: Bool
    let isActive: Bool
    let customization: HeartCustomization
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Glassmorphism container
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Heart shape
            HeartShape()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(pulseScale)
                .shadow(color: color.opacity(glowOpacity), radius: 10)
            
            // Customization overlay
            if let hairstyle = customization.hairstyle {
                Text(hairstyle.emoji)
                    .font(.title2)
                    .offset(y: -25)
            }
            
            if let accessory = customization.accessory {
                Text(accessory.emoji)
                    .font(.caption)
                    .offset(x: 20, y: -10)
            }
        }
        .onAppear {
            startPulseAnimation()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                triggerActiveAnimation()
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

struct HeartCustomization {
    var hairstyle: Hairstyle?
    var accessory: Accessory?
    var colorTint: Color?
    
    enum Hairstyle: CaseIterable {
        case short, long, curly, bun, hat
        
        var emoji: String {
            switch self {
            case .short: return "✂️"
            case .long: return "💇‍♀️"
            case .curly: return "🌀"
            case .bun: return "🥨"
            case .hat: return "🎩"
            }
        }
    }
    
    enum Accessory: CaseIterable {
        case glasses, bow, headband, scarf, crown
        
        var emoji: String {
            switch self {
            case .glasses: return "👓"
            case .bow: return "🎀"
            case .headband: return "👑"
            case .scarf: return "🧣"
            case .crown: return "👑"
            }
        }
    }
}

#Preview {
    HStack(spacing: 40) {
        HeartCharacter(
            color: Color(red: 139/255, green: 0/255, blue: 0/255),
            isUser: true,
            isActive: false,
            customization: HeartCustomization()
        )
        
        HeartCharacter(
            color: Color(red: 183/255, green: 110/255, blue: 121/255),
            isUser: false,
            isActive: true,
            customization: HeartCustomization(hairstyle: .curly, accessory: .bow)
        )
    }
    .padding()
    .background(Color.black)
}