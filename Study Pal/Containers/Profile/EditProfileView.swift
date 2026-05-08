import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var dateOfBirth = ""
    @State private var gender = "Male"
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Empty space to balance the header
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        // Profile Avatar Preview
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                                .shadow(radius: 10)
                            
                            Image(systemName: authViewModel.userProfile?.avatarIcon ?? "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            CustomInputField(title: "First Name", placeholder: "Enter first name", text: $firstName, icon: "person")
                            CustomInputField(title: "Last Name", placeholder: "Enter last name", text: $lastName, icon: "person.fill")
                            CustomInputField(title: "Email", placeholder: "example@mail.com", text: $email, icon: "envelope", isEditable: false)
                            CustomInputField(title: "Date of Birth", placeholder: "YYYY-MM-DD", text: $dateOfBirth, icon: "calendar")
                            
                            // Gender Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                Menu {
                                    ForEach(genders, id: \.self) { g in
                                        Button(g) { gender = g }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "person.2")
                                            .foregroundColor(.blue)
                                        Text(gender)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 10)
                                }
                                Text(isLoading ? "Saving..." : "Save Changes")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let profile = authViewModel.userProfile {
                firstName = profile.firstName
                lastName = profile.lastName
                email = profile.email
                dateOfBirth = profile.dateOfBirth
                gender = profile.gender
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Update Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage == "Profile updated successfully!" {
                    dismiss()
                }
            })
        }
    }
    
    private func saveProfile() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let fields: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "dateOfBirth": dateOfBirth,
            "gender": gender
        ]
        
        authViewModel.updateUserProfile(fields: fields) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    alertMessage = "Error updating profile: \(error.localizedDescription)"
                } else {
                    alertMessage = "Profile updated successfully!"
                }
                showAlert = true
            }
        }
    }
}

struct CustomInputField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var icon: String
    var isEditable: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                if isEditable {
                    TextField(placeholder, text: $text)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(title == "Email" ? .never : .words)
                } else {
                    Text(text)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(isEditable ? Color.white : Color.gray.opacity(0.1)))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
