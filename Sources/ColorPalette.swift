import SwiftUI

extension Color {
    // TouchSync Color Palette
    static let touchSyncCrimson = Color(red: 139/255, green: 0/255, blue: 0/255)
    static let touchSyncRoseGold = Color(red: 183/255, green: 110/255, blue: 121/255)
    static let touchSyncAmber = Color(red: 255/255, green: 107/255, blue: 53/255)
    static let touchSyncPurple = Color(red: 74/255, green: 14/255, blue: 78/255)
    static let touchSyncCharcoal = Color(red: 28/255, green: 28/255, blue: 30/255)
    static let touchSyncCharcoalLight = Color(red: 44/255, green: 44/255, blue: 46/255)
}

struct GlassmorphismModifier: ViewModifier {
    let opacity: Double
    let blur: CGFloat
    let borderOpacity: Double
    
    init(opacity: Double = 0.15, blur: CGFloat = 20, borderOpacity: Double = 0.2) {
        self.opacity = opacity
        self.blur = blur
        self.borderOpacity = borderOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(opacity))
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
            )
    }
}

extension View {
    func glassmorphism(opacity: Double = 0.15, blur: CGFloat = 20, borderOpacity: Double = 0.2) -> some View {
        modifier(GlassmorphismModifier(opacity: opacity, blur: blur, borderOpacity: borderOpacity))
    }
}