import SwiftUI

enum DeepLinkDestination {
    case home
    case sendTouch
    case history
    case settings
    case partnerInvite(code: String)
}

@MainActor
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var activeDestination: DeepLinkDestination?
    
    func handleURL(_ url: URL) {
        guard url.scheme == "touchsync" else { return }
        
        switch url.host {
        case "send":
            activeDestination = .sendTouch
        case "history":
            activeDestination = .history
        case "settings":
            activeDestination = .settings
        case "invite":
            if let code = url.pathComponents.last {
                activeDestination = .partnerInvite(code: code)
            }
        default:
            activeDestination = .home
        }
    }
    
    func handleNotificationAction(_ action: String) {
        switch action {
        case "RESPOND_TOUCH", "SEND_TOUCH":
            activeDestination = .sendTouch
        default:
            break
        }
    }
    
    func clearDestination() {
        activeDestination = nil
    }
}

// MARK: - Deep Link Navigation View
struct DeepLinkNavigationView<Content: View>: View {
    @StateObject private var deepLinkManager = DeepLinkManager.shared
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .onReceive(NotificationCenter.default.publisher(for: .openTouchSending)) { _ in
                deepLinkManager.activeDestination = .sendTouch
            }
            .sheet(item: Binding<DeepLinkDestination?>(
                get: { deepLinkManager.activeDestination },
                set: { _ in deepLinkManager.clearDestination() }
            )) { destination in
                destinationView(for: destination)
            }
    }
    
    @ViewBuilder
    private func destinationView(for destination: DeepLinkDestination) -> some View {
        switch destination {
        case .sendTouch:
            NavigationView {
                GestureLibraryView()
                    .navigationTitle("Send Touch")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                deepLinkManager.clearDestination()
                            }
                        }
                    }
            }
        case .history:
            NavigationView {
                TouchHistoryView()
                    .navigationTitle("Touch History")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                deepLinkManager.clearDestination()
                            }
                        }
                    }
            }
        case .settings:
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                deepLinkManager.clearDestination()
                            }
                        }
                    }
            }
        case .partnerInvite(let code):
            PartnerInviteView(inviteCode: code)
        case .home:
            EmptyView()
        }
    }
}

// MARK: - Partner Invite View
struct PartnerInviteView: View {
    let inviteCode: String
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Heart characters
                HStack(spacing: 20) {
                    HeartCharacter(
                        size: 60,
                        primaryColor: ColorPalette.crimson,
                        secondaryColor: ColorPalette.roseGold,
                        isAnimating: true
                    )
                    
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(ColorPalette.amber)
                    
                    HeartCharacter(
                        size: 60,
                        primaryColor: ColorPalette.deepPurple,
                        secondaryColor: ColorPalette.roseGold,
                        isAnimating: true
                    )
                }
                
                VStack(spacing: 12) {
                    Text("Partner Invitation")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("You've been invited to connect with your partner on TouchSync!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Invite Code: \(inviteCode)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: acceptInvite) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isProcessing ? "Connecting..." : "Accept Invitation")
                    }
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.crimson, in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isProcessing)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Join TouchSync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func acceptInvite() {
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.acceptPartnerInvite(inviteCode)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                }
            }
        }
    }
}

// Make DeepLinkDestination identifiable for sheet presentation
extension DeepLinkDestination: Identifiable {
    var id: String {
        switch self {
        case .home: return "home"
        case .sendTouch: return "sendTouch"
        case .history: return "history"
        case .settings: return "settings"
        case .partnerInvite(let code): return "invite_\(code)"
        }
    }
}