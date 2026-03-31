import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    // Simulate sign in for now
    func signIn() {
        isAuthenticated = true
    }
    
    func signOut() {
        isAuthenticated = false
    }
}
