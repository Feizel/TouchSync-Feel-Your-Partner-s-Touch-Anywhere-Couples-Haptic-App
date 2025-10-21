import SwiftUI
import Firebase

@main
struct TouchSyncApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            DeepLinkNavigationView {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(notificationManager)
            }
            .onOpenURL { url in
                DeepLinkManager.shared.handleURL(url)
            }
            .task {
                await notificationManager.requestPermission()
                notificationManager.setupNotificationCategories()
            }
        }
    }
}