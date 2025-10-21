import SwiftUI

struct TouchHistoryView: View {
    var body: some View {
        NavigationView {
            VStack {
                if true { // Empty state for now
                    VStack(spacing: 16) {
                        Text("💕💖")
                            .font(.system(size: 60))
                        
                        Text("No touches yet today")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Send your partner your first touch!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Send Touch") {
                            // Navigate to home view
                        }
                        .padding()
                        .background(Color(red: 139/255, green: 0/255, blue: 0/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    // Touch history list will go here
                    List {
                        // Placeholder for touch history cards
                    }
                }
            }
            .navigationTitle("Touch History")
        }
    }
}

#Preview {
    TouchHistoryView()
}