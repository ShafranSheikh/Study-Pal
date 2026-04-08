import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var forgotEmail = ""
    @State private var forgotMessage = ""
    @State private var showForgotAlert = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ZStack {
                        Color.white
                    }
                    .frame(height: proxy.size.height * 0.5)
                    Spacer(minLength: 0)
                }
            }
            .frame(maxHeight: .infinity)

            // Bottom Blue Area
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back,")
                        .font(.system(size: 34, weight: .bold))
                    Text("Signin to access your account")
                        .font(.system(size: 18))
                }
                .foregroundColor(.white)
                .padding(.top, 40)

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

                // Email Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    TextField("youremail@example.com", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }

                // Password Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    SecureField("*************", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)

                    Button("Forgot password?") {
                        forgotEmail = email
                        showForgotPassword = true
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.white)
                    .font(.subheadline)
                }

                // Sign In Button
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                    } else {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                    }
                }
                .disabled(authViewModel.isLoading)
                .padding(.top, 10)

                // Divider
                HStack {
                    Capsule().frame(height: 1).opacity(0.3)
                    Text("or continue with").font(.caption)
                    Capsule().frame(height: 1).opacity(0.3)
                }
                .foregroundColor(.white)

                // Apple Sign In Button (placeholder for Sign in with Apple)
                Button(action: {}) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Sign In with Apple")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(25)
                }

                Spacer()

                // Footer
                HStack {
                    Spacer()
                    Text("Don't have an account?")
                    Button("Sign up") {
                        authViewModel.errorMessage = nil
                        showSignUp = true
                    }.fontWeight(.bold)
                    Spacer()
                }
                .foregroundColor(.white)
                .font(.footnote)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
            .background(Color.blue)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.top)
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
        .alert("Reset Password", isPresented: $showForgotPassword) {
            TextField("Enter your email", text: $forgotEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            Button("Send Reset Email") {
                authViewModel.sendPasswordReset(email: forgotEmail) { message in
                    forgotMessage = message
                    showForgotAlert = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll send a password reset link to your email.")
        }
        .alert(forgotMessage, isPresented: $showForgotAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
