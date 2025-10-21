import SwiftUI
import CloudKit

struct HeartCustomization: Codable, Equatable {
    var primaryColor: String = "crimson"
    var secondaryColor: String = "roseGold"
    var accessory: HeartAccessory = .none
    var expression: HeartExpression = .happy
    var unlockLevel: Int = 1
    
    static let `default` = HeartCustomization()
}

enum HeartAccessory: String, CaseIterable, Codable {
    case none = "none"
    case bow = "bow"
    case hat = "hat"
    case glasses = "glasses"
    case crown = "crown"
    case flower = "flower"
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .bow: return "Bow Tie"
        case .hat: return "Top Hat"
        case .glasses: return "Glasses"
        case .crown: return "Crown"
        case .flower: return "Flower"
        }
    }
    
    var unlockLevel: Int {
        switch self {
        case .none: return 1
        case .bow: return 5
        case .hat: return 10
        case .glasses: return 15
        case .crown: return 25
        case .flower: return 20
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "circle"
        case .bow: return "bowtie"
        case .hat: return "hat"
        case .glasses: return "eyeglasses"
        case .crown: return "crown"
        case .flower: return "leaf"
        }
    }
}

enum HeartColorTheme: String, CaseIterable {
    case classic = "classic"
    case sunset = "sunset"
    case ocean = "ocean"
    case forest = "forest"
    case galaxy = "galaxy"
    case rose = "rose"
    
    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .sunset: return "Sunset"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .galaxy: return "Galaxy"
        case .rose: return "Rose"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .classic: return ColorPalette.crimson
        case .sunset: return ColorPalette.amber
        case .ocean: return .blue
        case .forest: return .green
        case .galaxy: return ColorPalette.deepPurple
        case .rose: return ColorPalette.roseGold
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .classic: return ColorPalette.roseGold
        case .sunset: return ColorPalette.crimson
        case .ocean: return .cyan
        case .forest: return .mint
        case .galaxy: return .indigo
        case .rose: return .pink
        }
    }
    
    var unlockLevel: Int {
        switch self {
        case .classic: return 1
        case .sunset: return 8
        case .ocean: return 12
        case .forest: return 16
        case .galaxy: return 22
        case .rose: return 18
        }
    }
}

@MainActor
class HeartCustomizationManager: ObservableObject {
    @Published var userCustomization = HeartCustomization.default
    @Published var partnerCustomization = HeartCustomization.default
    
    private let userDefaults = UserDefaults.standard
    private let cloudKitContainer = CKContainer.default()
    
    init() {
        loadCustomizations()
    }
    
    func updateUserCustomization(_ customization: HeartCustomization) {
        userCustomization = customization
        saveCustomizations()
        syncToCloudKit()
    }
    
    func isAccessoryUnlocked(_ accessory: HeartAccessory) -> Bool {
        let currentLevel = LevelingManager.shared.currentLevel
        return currentLevel >= accessory.unlockLevel
    }
    
    func isColorThemeUnlocked(_ theme: HeartColorTheme) -> Bool {
        let currentLevel = LevelingManager.shared.currentLevel
        return currentLevel >= theme.unlockLevel
    }
    
    private func loadCustomizations() {
        if let data = userDefaults.data(forKey: "userHeartCustomization"),
           let customization = try? JSONDecoder().decode(HeartCustomization.self, from: data) {
            userCustomization = customization
        }
        
        if let data = userDefaults.data(forKey: "partnerHeartCustomization"),
           let customization = try? JSONDecoder().decode(HeartCustomization.self, from: data) {
            partnerCustomization = customization
        }
    }
    
    private func saveCustomizations() {
        if let data = try? JSONEncoder().encode(userCustomization) {
            userDefaults.set(data, forKey: "userHeartCustomization")
        }
        
        if let data = try? JSONEncoder().encode(partnerCustomization) {
            userDefaults.set(data, forKey: "partnerHeartCustomization")
        }
    }
    
    private func syncToCloudKit() {
        guard let userId = AuthManager.shared.currentUser?.uid else { return }
        
        Task {
            do {
                let database = cloudKitContainer.privateCloudDatabase
                let recordID = CKRecord.ID(recordName: "heartCustomization_\(userId)")
                
                let record: CKRecord
                do {
                    record = try await database.record(for: recordID)
                } catch {
                    record = CKRecord(recordType: "HeartCustomization", recordID: recordID)
                }
                
                if let customizationData = try? JSONEncoder().encode(userCustomization) {
                    record["customization"] = String(data: customizationData, encoding: .utf8)
                    record["lastModified"] = Date()
                    
                    try await database.save(record)
                }
            } catch {
                print("CloudKit sync failed: \(error)")
            }
        }
    }
    
    func loadFromCloudKit() {
        guard let userId = AuthManager.shared.currentUser?.uid else { return }
        
        Task {
            do {
                let database = cloudKitContainer.privateCloudDatabase
                let recordID = CKRecord.ID(recordName: "heartCustomization_\(userId)")
                let record = try await database.record(for: recordID)
                
                if let customizationString = record["customization"] as? String,
                   let customizationData = customizationString.data(using: .utf8),
                   let customization = try? JSONDecoder().decode(HeartCustomization.self, from: customizationData) {
                    
                    await MainActor.run {
                        userCustomization = customization
                        saveCustomizations()
                    }
                }
            } catch {
                print("CloudKit load failed: \(error)")
            }
        }
    }
}