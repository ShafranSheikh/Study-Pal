import SwiftUI

struct AvatarSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAvatar: String
    var themeColor: Color
    
    let avatars = ["person.fill", "person.circle.fill", "person.crop.square.fill", "person.crop.circle.badge.checkmark", "person.crop.circle.badge.moon", "face.smiling", "graduationcap.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Choose Avatar")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(avatars, id: \.self) { avatar in
                            Image(systemName: avatar)
                                .font(.system(size: 35))
                                .foregroundColor(themeColor)
                                .padding()
                                .background(selectedAvatar == avatar ? themeColor.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    selectedAvatar = avatar
                                    dismiss()
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Select Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }.bold().foregroundColor(themeColor)
                }
            }
        }
    }
}

struct ThemeSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedThemeColor: Color
    
    let themes: [Color] = [.blue, .purple, .pink, .orange, .green, .indigo, .mint, .teal]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Choose Theme")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                        ForEach(themes, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.5), lineWidth: selectedThemeColor == color ? 3 : 0)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    selectedThemeColor = color
                                    dismiss()
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Select Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }.bold().foregroundColor(selectedThemeColor)
                }
            }
        }
    }
}
