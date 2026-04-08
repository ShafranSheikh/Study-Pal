import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var dateOfBirth = ""
    @State private var gender = "Male"
    @State private var password = ""
    @State private var confirmPassword = ""
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Master Background
                Color.white.ignoresSafeArea()
                
                // Underlay for scroll bounce at bottom
                VStack {
                    Spacer()
                    Color.blue.frame(height: geometry.size.height / 2).ignoresSafeArea()
                }
                
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 45, height: 45)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Empty space for white header
                        Spacer()
                            .frame(height: 80)
                        
                        // The Blue Form Container
                        VStack(alignment: .leading, spacing: 25) {
                            
                            // Header Text
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create Account")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Sign up to get started")
                                    .font(.title3)
                                    .opacity(0.9)
                            }
                            .foregroundColor(.white)
                            .padding(.top, 40)
                            
                            VStack(spacing: 18) {
                                // Custom input fields
                                CustomSignUpField(title: "First Name", placeholder: "Jhon", text: $firstName)
                                CustomSignUpField(title: "Last Name", placeholder: "Doe", text: $lastName)
                                CustomSignUpField(title: "Email", placeholder: "jhondoe@mail.com", text: $email, keyboardType: .emailAddress)
                                CustomSignUpField(title: "Date of Birth", placeholder: "yyyy-mm-dd", text: $dateOfBirth)
                                
                                // Gender Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gender")
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                    
                                    Menu {
                                        ForEach(genders, id: \.self) { g in
                                            Button(g) { gender = g }
                                        }
                                    } label: {
                                        HStack {
                                            Text(gender)
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 12, height: 12)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                CustomSignUpField(title: "Password", placeholder: "••••••••", text: $password, isSecure: true)
                                CustomSignUpField(title: "Confirm Password", placeholder: "••••••••", text: $confirmPassword, isSecure: true)
                            }
                            
                            // Error Message
                            if let errorMessage = authViewModel.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(errorMessage)
                                        .font(.subheadline)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            }

                            // Sign Up Button
                            Button(action: {
                                authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword,
                                    firstName: firstName,
                                    lastName: lastName,
                                    dateOfBirth: dateOfBirth,
                                    gender: gender
                                )
                            }) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                } else {
                                    Text("Sign Up")
                                        .font(.title3.bold())
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                        .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                                }
                            }
                            .disabled(authViewModel.isLoading)
                            .padding(.top, 15)
                            
                            // Footer
                            HStack {
                                Spacer()
                                Text("Already have an account?")
                                    .foregroundColor(.white.opacity(0.9))
                                Button("Sign in") {
                                    dismiss()
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                Spacer()
                            }
                            .font(.subheadline)
                            .padding(.top, 10)
                            .padding(.bottom, 60) // Extra padding for safe area
                            
                        }
                        .padding(.horizontal, 30)
                        .background(
                            Color.blue
                                .clipShape(CustomRoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
                        )
                    }
                    .frame(minHeight: geometry.size.height - 80)
                }
                .edgesIgnoringSafeArea(.bottom)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    struct CustomSignUpField: View {
        var title: String
        var placeholder: String
        @Binding var text: String
        var isSecure: Bool = false
        var keyboardType: UIKeyboardType = .default
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    // Helper to round specific corners safely
    struct CustomRoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
}
#Preview {
    SignUpView()
}
