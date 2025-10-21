import CoreData
import Foundation

@MainActor
class TouchRepository: ObservableObject {
    private let persistenceController = PersistenceController.shared
    
    @Published var recentTouches: [TouchRecord] = []
    @Published var favoriteTouches: [TouchRecord] = []
    
    func saveTouch(
        gestureType: String,
        senderId: String,
        receiverId: String,
        intensity: Float? = nil,
        drawingPath: String? = nil
    ) {
        let context = persistenceController.context
        
        let cachedTouch = CachedTouch(context: context)
        cachedTouch.touchId = UUID()
        cachedTouch.gestureType = gestureType
        cachedTouch.senderId = senderId
        cachedTouch.receiverId = receiverId
        cachedTouch.timestamp = Date()
        cachedTouch.isFavorite = false
        cachedTouch.isSynced = false
        
        // Store additional data as JSON
        var metadata: [String: Any] = [:]
        if let intensity = intensity {
            metadata["intensity"] = intensity
        }
        if let drawingPath = drawingPath {
            metadata["drawingPath"] = drawingPath
        }
        
        if !metadata.isEmpty,
           let jsonData = try? JSONSerialization.data(withJSONObject: metadata),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // Store encrypted metadata (simplified for demo)
            cachedTouch.setValue(jsonString, forKey: "metadata")
        }
        
        persistenceController.save()
        loadRecentTouches()
    }
    
    func loadRecentTouches() {
        let context = persistenceController.context
        let request: NSFetchRequest<CachedTouch> = CachedTouch.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CachedTouch.timestamp, ascending: false)]
        request.fetchLimit = 50
        
        do {
            let cachedTouches = try context.fetch(request)
            recentTouches = cachedTouches.compactMap { TouchRecord(from: $0) }
        } catch {
            print("Failed to load touches: \(error)")
        }
    }
    
    func loadFavoriteTouches() {
        let context = persistenceController.context
        let request: NSFetchRequest<CachedTouch> = CachedTouch.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CachedTouch.timestamp, ascending: false)]
        
        do {
            let cachedTouches = try context.fetch(request)
            favoriteTouches = cachedTouches.compactMap { TouchRecord(from: $0) }
        } catch {
            print("Failed to load favorite touches: \(error)")
        }
    }
    
    func toggleFavorite(touchId: UUID) {
        let context = persistenceController.context
        let request: NSFetchRequest<CachedTouch> = CachedTouch.fetchRequest()
        request.predicate = NSPredicate(format: "touchId == %@", touchId as CVarArg)
        
        do {
            if let cachedTouch = try context.fetch(request).first {
                cachedTouch.isFavorite.toggle()
                persistenceController.save()
                loadRecentTouches()
                loadFavoriteTouches()
            }
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
    
    func deleteOldTouches(olderThan days: Int) {
        let context = persistenceController.context
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let request: NSFetchRequest<CachedTouch> = CachedTouch.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@ AND isFavorite == NO", cutoffDate as NSDate)
        
        do {
            let oldTouches = try context.fetch(request)
            for touch in oldTouches {
                context.delete(touch)
            }
            persistenceController.save()
            loadRecentTouches()
        } catch {
            print("Failed to delete old touches: \(error)")
        }
    }
}

struct TouchRecord: Identifiable {
    let id: UUID
    let gestureType: String
    let senderId: String
    let receiverId: String
    let timestamp: Date
    let isFavorite: Bool
    let intensity: Float?
    let drawingPath: String?
    
    init?(from cachedTouch: CachedTouch) {
        guard let id = cachedTouch.touchId,
              let gestureType = cachedTouch.gestureType,
              let senderId = cachedTouch.senderId,
              let receiverId = cachedTouch.receiverId,
              let timestamp = cachedTouch.timestamp else {
            return nil
        }
        
        self.id = id
        self.gestureType = gestureType
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.isFavorite = cachedTouch.isFavorite
        
        // Parse metadata
        if let metadataString = cachedTouch.value(forKey: "metadata") as? String,
           let metadataData = metadataString.data(using: .utf8),
           let metadata = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] {
            self.intensity = metadata["intensity"] as? Float
            self.drawingPath = metadata["drawingPath"] as? String
        } else {
            self.intensity = nil
            self.drawingPath = nil
        }
    }
    
    var isFromCurrentUser: Bool {
        // This would check against current user ID
        return true // Simplified for demo
    }
    
    var gestureIcon: String {
        switch gestureType {
        case "Squeeze Hand": return "🤝"
        case "Forehead Kiss": return "😘"
        case "Hug": return "🤗"
        case "Shoulder Tap": return "👋"
        case "Heart Trace": return "💖"
        case "Drawing": return "✏️"
        default: return "💕"
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}