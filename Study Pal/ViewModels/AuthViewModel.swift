import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var didJustSignOut: Bool = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var profileListener: ListenerRegistration?

    // Biometric Settings
    @Published var isBiometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricEnabled, forKey: "isBiometricEnabled")
        }
    }

    init() {
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: "isBiometricEnabled")
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
                if let uid = user?.uid {
                    self?.startListeningToProfile(uid: uid)
                } else {
                    self?.userProfile = nil
                    self?.profileListener = nil
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    
    private func startListeningToProfile(uid: String) {
        let listener = UserService.shared.listenToProfile(uid: uid) { [weak self] profile in
            DispatchQueue.main.async {
                self?.userProfile = profile
            }
        }
        profileListener = listener
    }

    
    func signIn(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                } else {
                    self?.currentUser = result?.user
                    self?.isAuthenticated = true
                    
                    
                    if self?.isBiometricEnabled == true {
                        self?.saveCredentialsToKeychain(email: email, password: password)
                    }
                }
            }
        }
    }
    
    //Biometric Sign In
    func signInWithBiometrics() {
        // Pre-check credentials
        guard KeychainHelper.shared.read(service: "study-pal-auth", account: "email") != nil,
              KeychainHelper.shared.read(service: "study-pal-auth", account: "password") != nil else {
            self.errorMessage = "No stored credentials found. Please sign in with password first."
            return
        }

        BiometricManager.shared.authenticateUser { [weak self] success, error in
            if success {
                guard let emailData = KeychainHelper.shared.read(service: "study-pal-auth", account: "email"),
                      let passwordData = KeychainHelper.shared.read(service: "study-pal-auth", account: "password"),
                      let email = String(data: emailData, encoding: .utf8),
                      let password = String(data: passwordData, encoding: .utf8) else {
                    self?.errorMessage = "Error reading stored credentials."
                    return
                }
                
                self?.signIn(email: email, password: password)
            } else if let error = error {
                self?.errorMessage = error
            }
        }
    }

    func enableBiometrics(password: String, completion: @escaping (Bool) -> Void) {
        guard let email = currentUser?.email else {
            completion(false)
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if error == nil {
                    self?.isBiometricEnabled = true
                    self?.saveCredentialsToKeychain(email: email, password: password)
                    completion(true)
                } else {
                    self?.errorMessage = "Incorrect password. Failed to enable biometrics."
                    completion(false)
                }
            }
        }
    }
    
    private func saveCredentialsToKeychain(email: String, password: String) {
        if let emailData = email.data(using: .utf8),
           let passwordData = password.data(using: .utf8) {
            KeychainHelper.shared.save(emailData, service: "study-pal-auth", account: "email")
            KeychainHelper.shared.save(passwordData, service: "study-pal-auth", account: "password")
        }
    }
    
    func clearKeychainCredentials() {
        KeychainHelper.shared.delete(service: "study-pal-auth", account: "email")
        KeychainHelper.shared.delete(service: "study-pal-auth", account: "password")
    }

    
    func signUp(email: String, password: String, confirmPassword: String,
                firstName: String, lastName: String,
                dateOfBirth: String = "", gender: String = "Other") {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                } else if let user = result?.user {
                    
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = "\(firstName) \(lastName)"
                    changeRequest.commitChanges { _ in }

                    
                    let profile = UserProfile.defaultProfile(
                        uid: user.uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        dateOfBirth: dateOfBirth,
                        gender: gender
                    )
                    UserService.shared.createProfile(profile) { err in
                        if let err = err {
                            print("Profile creation error: \(err)")
                        }
                    }

                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            }
        }
    }

    // Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            userProfile = nil
            isAuthenticated = false
            didJustSignOut = true
        } catch {
            errorMessage = "Failed to sign out. Please try again."
        }
    }

    // Password Reset
    func sendPasswordReset(email: String, completion: @escaping (String) -> Void) {
        guard !email.isEmpty else {
            completion("Please enter your email address.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(self.friendlyError(error))
            } else {
                completion("Password reset email sent! Check your inbox.")
            }
        }
    }

    // Update profile fields
    func updateUserProfile(fields: [String: Any]) {
        guard let uid = currentUser?.uid else { return }
        UserService.shared.updateProfile(uid: uid, fields: fields)
    }

    // Error Helpers
    private func friendlyError(_ error: Error) -> String {
        let err = error as NSError
        switch AuthErrorCode(rawValue: err.code) {
        case .invalidEmail:      return "The email address is not valid."
        case .wrongPassword:     return "Incorrect password. Please try again."
        case .userNotFound:      return "No account found with this email."
        case .emailAlreadyInUse: return "This email is already in use."
        case .weakPassword:      return "Password is too weak. Use at least 6 characters."
        case .networkError:      return "Network error. Please check your connection."
        default:
            print("Firebase Auth Error: \(err.code) — \(error.localizedDescription)")
            print("Full error: \(err)")
            return error.localizedDescription
        }
    }
}


