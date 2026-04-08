import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true

    @State private var showAvatarSheet = false
    @State private var showThemeSheet = false

    // Local state synced from Firestore profile
    @State private var selectedAvatar: String = "person.fill"
    @State private var selectedThemeColor: Color = .blue

    // Derived display values from real profile
    private var displayName: String {
        authViewModel.userProfile?.fullName ?? authViewModel.currentUser?.displayName ?? "User"
    }
    private var displayEmail: String {
        authViewModel.userProfile?.email ?? authViewModel.currentUser?.email ?? ""
    }
    private var userLevel: Int {
        authViewModel.userProfile?.level ?? 1
    }
    private var userXP: Int {
        authViewModel.userProfile?.xp ?? 0
    }
    private var userID: String {
        String((authViewModel.currentUser?.uid ?? "").prefix(8)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.09)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {

                        Text("Profile")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.horizontal)

                        // MARK: - Profile Card
                        VStack(spacing: 20) {
                            HStack(alignment: .top) {
                                // Avatar
                                Image(systemName: selectedAvatar)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(displayName)
                                        .font(.title3.bold())
                                    Text(displayEmail)
                                        .font(.subheadline)
                                        .tint(.white)
                                    Text("ID: \(userID)")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                                .foregroundColor(.white)

                                Spacer()

                                NavigationLink(destination: EditProfileView()) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }

                            // XP Progress Bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Level \(userLevel)")
                                    Spacer()
                                    Text("\(userXP)/100 XP")
                                }
                                .font(.caption.bold())
                                .foregroundColor(.white)

                                let progress = min(CGFloat(userXP) / 100.0, 1.0)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(height: 12)
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: max(progress * geo.size.width, 10), height: 12)
                                    }
                                }
                                .frame(height: 12)
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
                        }
                        .padding(25)
                        .background(
                            LinearGradient(
                                colors: [.purple, selectedThemeColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .padding(.horizontal)

                        // MARK: - Personalization Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Personalization")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                Button(action: { showAvatarSheet = true }) {
                                    SettingsRow(icon: "person", title: "Avatar", subtitle: "Choose your profile icon")
                                }
                                .buttonStyle(PlainButtonStyle())

                                Divider().padding(.leading, 60)

                                Button(action: { showThemeSheet = true }) {
                                    SettingsRow(icon: "paintpalette", title: "Color Theme", subtitle: "Customize your colors", hasColorPreview: true, themeColor: selectedThemeColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }

                        // MARK: - Settings Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Settings")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ToggleRow(icon: "bell", title: "Notifications", subtitle: "Get deadline reminders", isOn: $notificationsEnabled)
                                Divider().padding(.leading, 60)
                                ToggleRow(icon: "faceid", title: "Biometric Lock", subtitle: "Use FaceID / TouchID", isOn: $biometricEnabled)
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }

                        // MARK: - Log Out Button
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.black)
                                .cornerRadius(50)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showAvatarSheet, onDismiss: saveAvatar) {
                    AvatarSelectionSheet(selectedAvatar: $selectedAvatar, themeColor: selectedThemeColor)
                        .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showThemeSheet, onDismiss: saveTheme) {
                    ThemeSelectionSheet(selectedThemeColor: $selectedThemeColor)
                        .presentationDetents([.fraction(0.4), .medium])
                }
            }
        }
        // Sync local state when Firestore profile loads or changes
        .onReceive(authViewModel.$userProfile) { profile in
            if let profile = profile {
                selectedAvatar = profile.avatarIcon
                selectedThemeColor = Color(hex: profile.themeColor) ?? .blue
            }
        }
    }

    // MARK: - Save personalization back to Firestore
    private func saveAvatar() {
        authViewModel.updateUserProfile(fields: ["avatarIcon": selectedAvatar])
    }

    private func saveTheme() {
        authViewModel.updateUserProfile(fields: ["themeColor": selectedThemeColor.toHex() ?? "#007AFF"])
    }

    // MARK: - Helper Views
    struct SettingsRow: View {
        let icon: String
        let title: String
        let subtitle: String
        var hasColorPreview: Bool = false
        var themeColor: Color = .blue

        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading) {
                    Text(title).font(.body.bold())
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }

                Spacer()

                if hasColorPreview {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, themeColor], startPoint: .top, endPoint: .bottom))
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }

    struct ToggleRow: View {
        let icon: String
        let title: String
        let subtitle: String
        @Binding var isOn: Bool

        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading) {
                    Text(title).font(.body.bold())
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
            .padding()
        }
    }
}
