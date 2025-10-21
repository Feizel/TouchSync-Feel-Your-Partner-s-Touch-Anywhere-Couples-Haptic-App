import SwiftUI

struct TouchHistoryView: View {
    @StateObject private var touchRepository = TouchRepository()
    @StateObject private var hapticsManager = HapticsManager.shared
    @State private var showingFavoritesOnly = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Toggle
                HStack {
                    Button(showingFavoritesOnly ? "All Touches" : "Favorites Only") {
                        showingFavoritesOnly.toggle()
                        if showingFavoritesOnly {
                            touchRepository.loadFavoriteTouches()
                        } else {
                            touchRepository.loadRecentTouches()
                        }
                    }
                    .foregroundColor(.touchSyncAmber)
                    
                    Spacer()
                    
                    Text("\(displayedTouches.count) touches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                if displayedTouches.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Text("💕💖")
                            .font(.system(size: 60))
                        
                        Text(showingFavoritesOnly ? "No favorite touches yet" : "No touches yet today")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Send your partner your first touch!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    // Touch History List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(displayedTouches) { touch in
                                TouchHistoryCard(touch: touch) {
                                    replayTouch(touch)
                                } onFavorite: {
                                    touchRepository.toggleFavorite(touchId: touch.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Touch History")
            .onAppear {
                touchRepository.loadRecentTouches()
                touchRepository.loadFavoriteTouches()
            }
        }
    }
    
    private var displayedTouches: [TouchRecord] {
        showingFavoritesOnly ? touchRepository.favoriteTouches : touchRepository.recentTouches
    }
    
    private func replayTouch(_ touch: TouchRecord) {
        if let gesture = HapticGesture.allGestures.first(where: { $0.name == touch.gestureType }) {
            hapticsManager.playGesture(gesture)
        } else if let intensity = touch.intensity {
            hapticsManager.playRealtimeTouch(intensity: intensity)
        }
    }
}

#Preview {
    TouchHistoryView()
}