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
                    
                    // Heart Characters
                    HeartCharactersPairView()
                        .padding(.horizontal)
                    
                    // Connection Meter with Daily Goals
                    ConnectionMeterView()
                        .padding(.horizontal)
                    
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



#Preview {
    HomeView()
        .environmentObject(AuthManager())
}