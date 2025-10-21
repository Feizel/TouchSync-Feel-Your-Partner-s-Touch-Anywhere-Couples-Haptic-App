import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Connection") {
                    HStack {
                        Text("Daily Touch Goal")
                        Spacer()
                        Text("5")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Availability Status")
                        Spacer()
                        Text("Available")
                            .foregroundColor(.green)
                    }
                    
                    if let partnerId = authManager.partnerId {
                        HStack {
                            Text("Partner")
                            Spacer()
                            Text("Connected")
                                .foregroundColor(.green)
                        }
                    } else {
                        Button("Link Partner") {
                            // Show partner linking
                        }
                        .foregroundColor(Color(red: 139/255, green: 0/255, blue: 0/255))
                    }
                }
                
                Section("Notifications") {
                    HStack {
                        Text("Touch Received")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Text("Connection Reminder")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Text("Streak Protection")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("Account") {
                    if let email = authManager.currentUser?.email {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Sign Out") {
                        try? authManager.signOut()
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}