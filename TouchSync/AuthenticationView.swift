import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingPartnerLink = false
    @State private var inviteCode = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo/Header
            VStack(spacing: 8) {
                Text("💕")
                    .font(.system(size: 60))
                
                Text("TouchSync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 139/255, green: 0/255, blue: 0/255))
                
                Text("Feel them from anywhere")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Auth Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: authenticate) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isSignUp ? "Sign Up" : "Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 139/255, green: 0/255, blue: 0/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                    isSignUp.toggle()
                    errorMessage = ""
                }
                .foregroundColor(Color(red: 139/255, green: 0/255, blue: 0/255))
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Partner Link Button (only show after sign up)
            if authManager.isAuthenticated && authManager.partnerId == nil {
                Button("Link with Partner") {
                    showingPartnerLink = true
                }
                .padding()
                .background(Color(red: 183/255, green: 110/255, blue: 121/255))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showingPartnerLink) {
            PartnerLinkView()
        }
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, password: password)
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct PartnerLinkView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var inviteCode = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var myInviteCode = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Connect with Your Partner")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    Text("Your Invite Code")
                        .font(.headline)
                    
                    Text(myInviteCode)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("Share this code with your partner")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(spacing: 16) {
                    Text("Enter Partner's Code")
                        .font(.headline)
                    
                    TextField("Partner's invite code", text: $inviteCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textCase(.uppercase)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button("Link Partner") {
                        linkPartner()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 139/255, green: 0/255, blue: 0/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(inviteCode.isEmpty || isLoading)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            myInviteCode = authManager.generateInviteCode()
        }
    }
    
    private func linkPartner() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authManager.linkPartner(inviteCode: inviteCode.uppercased())
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager())
}