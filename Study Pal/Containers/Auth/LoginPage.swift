import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    // Top Section (30% height)
                    ZStack {
                        Color.white
                        // If you have the image, uncomment the line below:
                        // Image("pattern").resizable(resizingMode: .tile).opacity(0.1)
                    }
                    .frame(height: proxy.size.height * 0.3)

                    // Bottom Section (70% height) spacer to preserve existing structure
                    Spacer(minLength: 0)
                }
            }
            .frame(maxHeight: .infinity)
            
            // 2. Bottom Section (Blue Area)
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Text
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back,")
                        .font(.system(size: 34, weight: .bold))
                    Text("Signin to access your account")
                        .font(.system(size: 18))
                }
                .foregroundColor(.white)
                .padding(.top, 40)
                
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
                        // Action here
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.white)
                    .font(.subheadline)
                }
                
                // Sign In Button
                Button(action: {
                    authViewModel.signIn()
                }) {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .foregroundColor(.blue) 
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.top, 10)
                
                // Divider Row
                HStack {
                    Capsule().frame(height: 1).opacity(0.3)
                    Text("or continue with").font(.caption)
                    Capsule().frame(height: 1).opacity(0.3)
                }
                .foregroundColor(.white)
                
                // Apple Sign In Button
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
                    Button("Sign up") {}.fontWeight(.bold)
                    Spacer()
                }
                .foregroundColor(.white)
                .font(.footnote)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
            .background(Color.blue) // Uses standard system blue
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

