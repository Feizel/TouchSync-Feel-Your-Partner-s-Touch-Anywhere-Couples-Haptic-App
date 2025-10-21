import SwiftUI

struct HeartCharactersPairView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var connectionStrength: Double = 0.0
    @State private var isConnected: Bool = false
    @State private var userHeartActive: Bool = false
    @State private var partnerHeartActive: Bool = false
    
    private let notificationCenter = NotificationCenter.default
    
    var body: some View {
        VStack(spacing: 16) {
            // Heart Characters with Connection Line
            HStack(spacing: 0) {
                // User Heart
                HeartCharacter(
                    color: Color(red: 139/255, green: 0/255, blue: 0/255),
                    isUser: true,
                    isActive: userHeartActive,
                    customization: HeartCustomization()
                )
                
                // Connection Line
                ConnectionLine(
                    strength: connectionStrength,
                    isActive: isConnected
                )
                .frame(width: 80, height: 6)
                
                // Partner Heart
                HeartCharacter(
                    color: Color(red: 183/255, green: 110/255, blue: 121/255),
                    isUser: false,
                    isActive: partnerHeartActive,
                    customization: HeartCustomization(hairstyle: .curly)
                )
            }
            
            // Connection Status
            VStack(spacing: 4) {
                if authManager.partnerId != nil {
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Waiting for partner...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text("Tap hearts to send love")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .onAppear {
            updateConnectionStatus()
            setupNotifications()
        }
        .onDisappear {
            removeNotifications()
        }
        .onTapGesture {
            sendHeartbeat()
        }
    }
    
    private func updateConnectionStatus() {
        isConnected = authManager.partnerId != nil
        connectionStrength = isConnected ? 0.8 : 0.2
    }
    
    private func sendHeartbeat() {
        // Animate user heart
        userHeartActive = true
        
        // Simulate partner response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            partnerHeartActive = true
            
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                userHeartActive = false
                partnerHeartActive = false
            }
        }
    }
    
    private func setupNotifications() {
        notificationCenter.addObserver(
            forName: .hapticGestureStarted,
            object: nil,
            queue: .main
        ) { _ in
            userHeartActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                userHeartActive = false
            }
        }
        
        notificationCenter.addObserver(
            forName: .drawingStarted,
            object: nil,
            queue: .main
        ) { _ in
            userHeartActive = true
        }
        
        notificationCenter.addObserver(
            forName: .drawingEnded,
            object: nil,
            queue: .main
        ) { _ in
            userHeartActive = false
        }
        
        notificationCenter.addObserver(
            forName: .partnerTouchReceived,
            object: nil,
            queue: .main
        ) { _ in
            partnerHeartActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                partnerHeartActive = false
            }
        }
    }
    
    private func removeNotifications() {
        notificationCenter.removeObserver(self)
    }
}

struct ConnectionLine: View {
    let strength: Double
    let isActive: Bool
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base line
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.1))
            
            // Active connection line
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 139/255, green: 0/255, blue: 0/255),
                            Color(red: 255/255, green: 107/255, blue: 53/255),
                            Color(red: 183/255, green: 110/255, blue: 121/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(x: strength, y: 1.0, anchor: .leading)
                .opacity(isActive ? 1.0 : 0.3)
            
            // Pulse animation
            if isActive {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 20, height: 6)
                    .offset(x: animationOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                            animationOffset = 60
                        }
                    }
            }
        }
    }
}

#Preview {
    HeartCharactersPairView()
        .environmentObject(AuthManager())
        .padding()
        .background(Color.black)
}