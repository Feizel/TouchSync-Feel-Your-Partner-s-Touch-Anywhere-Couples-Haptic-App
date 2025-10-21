import UserNotifications
import FirebaseMessaging
import SwiftUI

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasPermission = false
    @Published var fcmToken: String?
    
    override init() {
        super.init()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            hasPermission = granted
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    func scheduleConnectionReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Missing Your Touch 💕"
        content.body = "Your partner is waiting for your loving touch"
        content.sound = .default
        content.categoryIdentifier = "TOUCH_REMINDER"
        
        // Schedule for 2 hours after last activity
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
        let request = UNNotificationRequest(identifier: "connection_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendTouchReceivedNotification(gesture: String, from partnerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Touch Received 💖"
        content.body = "\(partnerName) sent you a \(gesture)"
        content.sound = .default
        content.categoryIdentifier = "TOUCH_RECEIVED"
        content.userInfo = ["gesture": gesture, "partner": partnerName]
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        // Update widget data
        updateWidgetData(lastTouch: gesture, partnerName: partnerName)
    }
    
    private func updateWidgetData(lastTouch: String, partnerName: String) {
        let sharedDefaults = UserDefaults(suiteName: "group.touchsync.app")
        sharedDefaults?.set(lastTouch, forKey: "lastTouch")
        sharedDefaults?.set(partnerName, forKey: "partnerName")
        
        // Update streak from StreakManager
        let streak = StreakManager.shared.currentStreak
        sharedDefaults?.set(streak, forKey: "connectionStreak")
        
        // Reload widget timeline
        WidgetKit.WidgetCenter.shared.reloadTimelines(ofKind: "TouchSyncWidget")
    }
    
    func setupNotificationCategories() {
        let touchReceivedCategory = UNNotificationCategory(
            identifier: "TOUCH_RECEIVED",
            actions: [
                UNNotificationAction(
                    identifier: "RESPOND_TOUCH",
                    title: "Send Touch Back",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "TOUCH_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "SEND_TOUCH",
                    title: "Send Touch",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            touchReceivedCategory,
            reminderCategory
        ])
    }
}

// MARK: - MessagingDelegate
extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken = fcmToken
        
        // Send token to Firebase for this user
        if let token = fcmToken {
            Task {
                await AuthManager.shared.updateFCMToken(token)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "RESPOND_TOUCH", "SEND_TOUCH":
            // Open app to touch sending screen
            NotificationCenter.default.post(name: .openTouchSending, object: nil)
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openTouchSending = Notification.Name("openTouchSending")
}

import WidgetKit