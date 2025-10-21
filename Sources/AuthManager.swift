import Foundation
import Firebase
import FirebaseAuth

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var partnerId: String?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                if user != nil {
                    await self?.loadUserProfile()
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        await createUserProfile(userId: result.user.uid, email: email)
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        partnerId = nil
    }
    
    func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    func linkPartner(inviteCode: String) async throws {
        guard let userId = currentUser?.uid else { throw AuthError.notAuthenticated }
        
        // Find partner by invite code
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("inviteCode", isEqualTo: inviteCode)
        let snapshot = try await query.getDocuments()
        
        guard let partnerDoc = snapshot.documents.first else {
            throw AuthError.invalidInviteCode
        }
        
        let partnerUserId = partnerDoc.documentID
        
        // Update both users with partner IDs
        try await db.collection("users").document(userId).updateData([
            "partnerId": partnerUserId,
            "linkedAt": Timestamp()
        ])
        
        try await db.collection("users").document(partnerUserId).updateData([
            "partnerId": userId,
            "linkedAt": Timestamp()
        ])
        
        partnerId = partnerUserId
    }
    
    func acceptPartnerInvite(_ inviteCode: String) async throws {
        try await linkPartner(inviteCode: inviteCode)
    }
    
    func updateFCMToken(_ token: String) async {
        guard let userId = currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        try? await db.collection("users").document(userId).updateData([
            "fcmToken": token,
            "tokenUpdatedAt": Timestamp()
        ])
    }
    
    private func createUserProfile(userId: String, email: String) async {
        let db = Firestore.firestore()
        let inviteCode = generateInviteCode()
        
        let userData: [String: Any] = [
            "email": email,
            "inviteCode": inviteCode,
            "createdAt": Timestamp(),
            "currentStreak": 0,
            "totalXP": 0,
            "currentLevel": 1,
            "fcmToken": ""
        ]
        
        try? await db.collection("users").document(userId).setData(userData)
    }
    
    private func loadUserProfile() async {
        guard let userId = currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                partnerId = data["partnerId"] as? String
            }
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
}

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidInviteCode
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .invalidInviteCode:
            return "Invalid invite code"
        }
    }
}