import SwiftUI

struct StreakDisplayView: View {
    @StateObject private var streakManager = StreakManager()
    
    var body: some View {
        HStack(spacing: 12) {
            // Fire Icon
            Text("🔥")
                .font(.title)
                .scaleEffect(streakManager.currentStreak > 0 ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: streakManager.currentStreak)
            
            // Streak Count
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakManager.currentStreak) Day Streak")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.touchSyncCrimson)
                
                Text(streakManager.getStreakMessage())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Freeze Tokens
            if streakManager.freezeTokens > 0 {
                HStack(spacing: 4) {
                    Text("❄️")
                        .font(.title3)
                    Text("x\(streakManager.freezeTokens)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.touchSyncCrimson.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    StreakDisplayView()
        .padding()
        .background(Color.black)
}