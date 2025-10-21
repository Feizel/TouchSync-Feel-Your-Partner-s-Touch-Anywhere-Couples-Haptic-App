import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Home")
                }
            
            TouchHistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color(red: 139/255, green: 0/255, blue: 0/255))
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}