import SwiftUI

struct GestureLibraryView: View {
    @StateObject private var hapticsManager = HapticsManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(HapticGesture.allGestures, id: \.name) { gesture in
                GestureButton(gesture: gesture) {
                    hapticsManager.playGesture(gesture)
                }
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
}

struct GestureButton: View {
    let gesture: HapticGesture
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(gesture.icon)
                    .font(.title2)
                
                Text(gesture.name)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(Color(hex: gesture.color).opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(Color(hex: gesture.color), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            // Preview haptic on long press
            HapticsManager.shared.playGesture(gesture)
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GestureLibraryView()
        .padding()
        .background(Color.black)
}