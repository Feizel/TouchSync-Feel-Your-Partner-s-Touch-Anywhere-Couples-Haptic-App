import SwiftUI

struct TouchHistoryCard: View {
    let touch: TouchRecord
    let onReplay: () -> Void
    let onFavorite: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Gesture Icon with Heart Character Reaction
            VStack {
                Text(touch.gestureIcon)
                    .font(.title2)
                
                // Small heart character reaction
                HeartCharacter(
                    color: touch.isFromCurrentUser ? .touchSyncCrimson : .touchSyncRoseGold,
                    isUser: touch.isFromCurrentUser,
                    isActive: false,
                    customization: HeartCustomization()
                )
                .scaleEffect(0.3)
                .frame(width: 30, height: 30)
            }
            
            // Touch Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(touch.gestureType)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(touch.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(touch.isFromCurrentUser ? "You sent" : "Partner sent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let intensity = touch.intensity {
                        Text("• \(Int(intensity * 100))% intensity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action Buttons
            VStack(spacing: 8) {
                Button(action: onReplay) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.touchSyncAmber)
                }
                
                Button(action: onFavorite) {
                    Image(systemName: touch.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(touch.isFavorite ? .red : .secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: touch.isFromCurrentUser ? "#8B0000" : "#B76E79").opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color(hex: touch.isFromCurrentUser ? "#8B0000" : "#B76E79").opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            onReplay()
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Long press for preview
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TouchHistoryCard(
            touch: TouchRecord(
                id: UUID(),
                gestureType: "Hug",
                senderId: "user1",
                receiverId: "user2",
                timestamp: Date().addingTimeInterval(-300),
                isFavorite: false,
                intensity: 0.8,
                drawingPath: nil
            ) ?? TouchRecord(
                id: UUID(),
                gestureType: "Hug",
                senderId: "user1",
                receiverId: "user2",
                timestamp: Date(),
                isFavorite: false,
                intensity: nil,
                drawingPath: nil
            )!,
            onReplay: {},
            onFavorite: {}
        )
        
        TouchHistoryCard(
            touch: TouchRecord(
                id: UUID(),
                gestureType: "Heart Trace",
                senderId: "user2",
                receiverId: "user1",
                timestamp: Date().addingTimeInterval(-1800),
                isFavorite: true,
                intensity: 0.6,
                drawingPath: nil
            )!,
            onReplay: {},
            onFavorite: {}
        )
    }
    .padding()
    .background(Color.black)
}