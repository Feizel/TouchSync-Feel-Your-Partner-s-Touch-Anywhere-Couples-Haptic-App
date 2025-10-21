import Foundation
import FirebaseDatabase
import CryptoKit

@MainActor
class RealtimeManager: ObservableObject {
    private let database = Database.database()
    private var sessionRef: DatabaseReference?
    private var currentSessionId: String?
    
    @Published var isConnected = false
    @Published var partnerOnline = false
    
    func startSession(userId: String, partnerId: String) {
        let sessionId = "\(min(userId, partnerId))_\(max(userId, partnerId))"
        currentSessionId = sessionId
        
        sessionRef = database.reference().child("touches").child(sessionId)
        
        // Set up session data
        sessionRef?.setValue([
            "user1Id": min(userId, partnerId),
            "user2Id": max(userId, partnerId),
            "createdAt": ServerValue.timestamp()
        ])
        
        // Listen for partner's touches
        sessionRef?.child("events").observe(.childAdded) { [weak self] snapshot in
            self?.handleIncomingTouch(snapshot)
        }
        
        // Set presence
        setPresence(userId: userId, online: true)
        
        isConnected = true
    }
    
    func sendTouch(point: CGPoint, intensity: Float, userId: String) {
        guard let sessionRef = sessionRef else { return }
        
        let touchData: [String: Any] = [
            "senderId": userId,
            "x": point.x,
            "y": point.y,
            "intensity": intensity,
            "timestamp": ServerValue.timestamp()
        ]
        
        // Encrypt touch data before sending
        if let encryptedData = encryptTouchData(touchData) {
            sessionRef.child("events").childByAutoId().setValue(encryptedData)
        }
        
        // Save drawing touch to local storage
        Task { @MainActor in
            let touchRepo = TouchRepository()
            touchRepo.saveTouch(
                gestureType: "Drawing",
                senderId: userId,
                receiverId: "partner",
                intensity: intensity,
                drawingPath: "\(point.x),\(point.y)"
            )
        }
    }
    
    func sendGesture(_ gesture: HapticGesture, userId: String) {
        guard let sessionRef = sessionRef else { return }
        
        let gestureData: [String: Any] = [
            "senderId": userId,
            "gestureType": gesture.name,
            "timestamp": ServerValue.timestamp()
        ]
        
        if let encryptedData = encryptTouchData(gestureData) {
            sessionRef.child("events").childByAutoId().setValue(encryptedData)
        }
        
        // Save to local storage
        Task { @MainActor in
            let touchRepo = TouchRepository()
            touchRepo.saveTouch(
                gestureType: gesture.name,
                senderId: userId,
                receiverId: "partner", // Would be actual partner ID
                intensity: nil,
                drawingPath: nil
            )
        }
    }
    
    private func handleIncomingTouch(_ snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any],
              let decryptedData = decryptTouchData(data) else { return }
        
        // Process incoming touch
        if let x = decryptedData["x"] as? Double,
           let y = decryptedData["y"] as? Double,
           let intensity = decryptedData["intensity"] as? Float {
            
            let point = CGPoint(x: x, y: y)
            
            // Play haptic feedback
            HapticsManager.shared.playRealtimeTouch(intensity: intensity)
            
            // Send notification if app is in background
            NotificationManager.shared.sendTouchReceivedNotification(
                gesture: "Drawing Touch",
                from: "Partner"
            )
            
            // Save received touch to local storage
            Task { @MainActor in
                let touchRepo = TouchRepository()
                touchRepo.saveTouch(
                    gestureType: "Drawing",
                    senderId: "partner",
                    receiverId: "user",
                    intensity: intensity,
                    drawingPath: "\(point.x),\(point.y)"
                )
            }
            
            // Notify UI
            NotificationCenter.default.post(
                name: .partnerTouchReceived,
                object: ["point": point, "intensity": intensity]
            )
        }
        
        // Handle gesture touches
        if let gestureType = decryptedData["gestureType"] as? String {
            // Play haptic for gesture
            if let gesture = HapticsManager.shared.presetGestures.first(where: { $0.name == gestureType }) {
                HapticsManager.shared.playGesture(gesture)
            }
            
            // Send notification
            NotificationManager.shared.sendTouchReceivedNotification(
                gesture: gestureType,
                from: "Partner"
            )
            
            // Save to local storage
            Task { @MainActor in
                let touchRepo = TouchRepository()
                touchRepo.saveTouch(
                    gestureType: gestureType,
                    senderId: "partner",
                    receiverId: "user",
                    intensity: nil,
                    drawingPath: nil
                )
            }
        }
    }
    
    private func setPresence(userId: String, online: Bool) {
        let presenceRef = database.reference().child("presence").child(userId)
        
        if online {
            presenceRef.setValue([
                "online": true,
                "lastSeen": ServerValue.timestamp()
            ])
            
            // Remove presence when disconnected
            presenceRef.onDisconnectRemoveValue()
        } else {
            presenceRef.removeValue()
        }
    }
    
    private func encryptTouchData(_ data: [String: Any]) -> [String: Any]? {
        // Simple encryption for demo - in production use proper E2E encryption
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let key = getEncryptionKey() else { return nil }
        
        let sealedBox = try? AES.GCM.seal(jsonData, using: key)
        
        return [
            "encrypted": sealedBox?.combined?.base64EncodedString() ?? "",
            "timestamp": data["timestamp"] ?? ServerValue.timestamp()
        ]
    }
    
    private func decryptTouchData(_ data: [String: Any]) -> [String: Any]? {
        guard let encryptedString = data["encrypted"] as? String,
              let encryptedData = Data(base64Encoded: encryptedString),
              let key = getEncryptionKey() else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any]
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    private func getEncryptionKey() -> SymmetricKey? {
        // In production, derive this from partner linking process
        let keyString = "TouchSyncDemoKey32CharactersLong"
        guard let keyData = keyString.data(using: .utf8) else { return nil }
        return SymmetricKey(data: keyData)
    }
    
    func endSession() {
        sessionRef?.removeAllObservers()
        sessionRef = nil
        currentSessionId = nil
        isConnected = false
    }
}

extension Notification.Name {
    static let partnerTouchReceived = Notification.Name("partnerTouchReceived")
}