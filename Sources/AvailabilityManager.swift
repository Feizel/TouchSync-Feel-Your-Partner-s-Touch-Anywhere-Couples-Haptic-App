import SwiftUI
import Firebase

enum AvailabilityStatus: String, CaseIterable {
    case available = "available"
    case busy = "busy"
    case sleeping = "sleeping"
    
    var displayName: String {
        switch self {
        case .available: return "Available"
        case .busy: return "Busy"
        case .sleeping: return "Sleeping"
        }
    }
    
    var icon: String {
        switch self {
        case .available: return "heart.fill"
        case .busy: return "minus.circle.fill"
        case .sleeping: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .available: return ColorPalette.amber
        case .busy: return ColorPalette.roseGold
        case .sleeping: return ColorPalette.deepPurple
        }
    }
    
    var heartExpression: HeartExpression {
        switch self {
        case .available: return .happy
        case .busy: return .focused
        case .sleeping: return .sleepy
        }
    }
}

enum HeartExpression {
    case happy, focused, sleepy
    
    var eyeOffset: CGFloat {
        switch self {
        case .happy: return 0
        case .focused: return -2
        case .sleepy: return 1
        }
    }
    
    var eyeScale: CGFloat {
        switch self {
        case .happy: return 1.0
        case .focused: return 0.8
        case .sleepy: return 0.6
        }
    }
}

@MainActor
class AvailabilityManager: ObservableObject {
    static let shared = AvailabilityManager()
    
    @Published var currentStatus: AvailabilityStatus = .available
    @Published var partnerStatus: AvailabilityStatus = .available
    @Published var lastStatusUpdate: Date = Date()
    
    private let database = Database.database().reference()
    private var statusListener: DatabaseHandle?
    
    init() {
        setupStatusListener()
        updateStatus(.available)
    }
    
    func updateStatus(_ status: AvailabilityStatus) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        currentStatus = status
        lastStatusUpdate = Date()
        
        let statusData: [String: Any] = [
            "status": status.rawValue,
            "timestamp": ServerValue.timestamp()
        ]
        
        database.child("availability").child(userId).setValue(statusData)
        
        // Auto-schedule sleep mode for nighttime
        if status == .sleeping {
            scheduleAutoWakeUp()
        }
    }
    
    private func setupStatusListener() {
        guard let userId = Auth.auth().currentUser?.uid,
              let partnerId = AuthManager.shared.partnerId else { return }
        
        statusListener = database.child("availability").child(partnerId).observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let data = snapshot.value as? [String: Any],
                  let statusString = data["status"] as? String,
                  let status = AvailabilityStatus(rawValue: statusString) else { return }
            
            DispatchQueue.main.async {
                self.partnerStatus = status
            }
        }
    }
    
    private func scheduleAutoWakeUp() {
        // Schedule to automatically set to available at 7 AM
        let calendar = Calendar.current
        let now = Date()
        
        guard let tomorrow7AM = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 7, minute: 0),
            matchingPolicy: .nextTime
        ) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! 🌅"
        content.body = "Ready to connect with your partner?"
        content.categoryIdentifier = "WAKE_UP"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.hour, .minute], from: tomorrow7AM),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: "auto_wake_up", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func canReceiveTouch() -> Bool {
        return currentStatus != .sleeping
    }
    
    func shouldShowBusyWarning() -> Bool {
        return partnerStatus == .busy
    }
    
    deinit {
        if let listener = statusListener {
            database.removeObserver(withHandle: listener)
        }
    }
}

// MARK: - Availability Status View
struct AvailabilityStatusView: View {
    @StateObject private var availabilityManager = AvailabilityManager.shared
    @State private var showingStatusPicker = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Current user status
            Button(action: { showingStatusPicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: availabilityManager.currentStatus.icon)
                        .foregroundColor(availabilityManager.currentStatus.color)
                        .font(.caption)
                    
                    Text(availabilityManager.currentStatus.displayName)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
            }
            
            Spacer()
            
            // Partner status (read-only)
            HStack(spacing: 6) {
                Image(systemName: availabilityManager.partnerStatus.icon)
                    .foregroundColor(availabilityManager.partnerStatus.color)
                    .font(.caption)
                
                Text("Partner: \(availabilityManager.partnerStatus.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .confirmationDialog("Set Your Status", isPresented: $showingStatusPicker) {
            ForEach(AvailabilityStatus.allCases, id: \.self) { status in
                Button(status.displayName) {
                    availabilityManager.updateStatus(status)
                }
            }
        }
    }
}