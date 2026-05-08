import Foundation
import LocalAuthentication

class BiometricManager {
    static let shared = BiometricManager()
    
    private init() {}
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        default:
            return .none
        }
    }
    
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate to sign in to Study Pal"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        let message = authenticationError?.localizedDescription ?? "Failed to authenticate"
                        completion(false, message)
                    }
                }
            }
        } else {
            let message = error?.localizedDescription ?? "Biometrics not available"
            completion(false, message)
        }
    }
}
