import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Availability Status Bar
                    AvailabilityStatusView()
                        .padding(.horizontal)
                    
                    // Streak Counter
                    StreakDisplayView()
                    
                    // Heart Characters
                    HeartCharactersPairView()
                        .padding(.horizontal)
                    
                    // Connection Meter with Daily Goals
                    ConnectionMeterView()
                        .padding(.horizontal)
                        .fullScreenCover(isPresented: .constant(false)) {
                            PerfectDayCelebrationView(isPresented: .constant(false), xpEarned: 50)
                        }
                    
                    // Touch Canvas
                    VStack(spacing: 12) {
                        Text("Touch Canvas")
                            .font(.headline)
                        
                        DrawingCanvasView(isActive: .constant(false))
                            .frame(height: 300)
                            .overlay(
                                VStack {
                                    HStack {
                                        // Small heart characters watching
                                        HeartCharacter(
                                            color: .touchSyncCrimson,
                                            isUser: true,
                                            isActive: false,
                                            customization: HeartCustomization()
                                        )
                                        .scaleEffect(0.4)
                                        
                                        Spacer()
                                        
                                        HeartCharacter(
                                            color: .touchSyncRoseGold,
                                            isUser: false,
                                            isActive: false,
                                            customization: HeartCustomization()
                                        )
                                        .scaleEffect(0.4)
                                    }
                                    .padding(.top, 8)
                                    
                                    Spacer()
                                    
                                    Text("Draw here to send touch")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.caption)
                                }
                                .allowsHitTesting(false)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Gesture Library
                    VStack(spacing: 8) {
                        Text("Quick Gestures")
                            .font(.headline)
                        
                        GestureLibraryView()
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