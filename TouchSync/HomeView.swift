import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Bar
                    HStack {
                        Text("Available")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        Text("❄️ x2")
                            .font(.caption)
                        
                        Text("🛡️ Level 1")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    
                    // Streak Counter
                    HStack {
                        Text("🔥")
                            .font(.title)
                        Text("0 Day Streak")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 139/255, green: 0/255, blue: 0/255))
                    }
                    
                    // Heart Characters Placeholder
                    VStack {
                        HStack(spacing: 40) {
                            // User Heart
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 139/255, green: 0/255, blue: 0/255), Color(red: 180/255, green: 0/255, blue: 0/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("💕")
                                        .font(.title)
                                )
                            
                            // Connection Line
                            Rectangle()
                                .fill(Color(red: 255/255, green: 107/255, blue: 53/255))
                                .frame(width: 60, height: 4)
                                .cornerRadius(2)
                            
                            // Partner Heart
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 183/255, green: 110/255, blue: 121/255), Color(red: 200/255, green: 130/255, blue: 140/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("💖")
                                        .font(.title)
                                )
                        }
                        
                        // Connection Meter
                        VStack(spacing: 8) {
                            Text("Connection Strength: 0%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ProgressView(value: 0.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 255/255, green: 107/255, blue: 53/255)))
                                .frame(height: 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                            
                            Text("Your bond needs attention 💙")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    .padding()
                    
                    // Daily Goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Goals")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            GoalRow(icon: "💌", title: "Touch Goal", progress: "0/5 Touches Sent", isComplete: false)
                            GoalRow(icon: "💬", title: "Response Goal", progress: "0/3 Responses", isComplete: false)
                            GoalRow(icon: "⏰", title: "Quality Goal", progress: "Quality Time: 0/60 sec", isComplete: false)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Canvas Placeholder
                    VStack {
                        Text("Touch Canvas")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 300)
                            .cornerRadius(20)
                            .overlay(
                                Text("Draw here to send touch")
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("TouchSync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GoalRow: View {
    let icon: String
    let title: String
    let progress: String
    let isComplete: Bool
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(progress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .secondary)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}