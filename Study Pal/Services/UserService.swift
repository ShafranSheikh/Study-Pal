import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Collection reference scoped to current user
    private func userDocument(uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    // MARK: - Create profile on first sign-up
    func createProfile(_ profile: UserProfile, completion: @escaping (Error?) -> Void) {
        do {
            try userDocument(uid: profile.id).setData(from: profile, completion: completion)
        } catch {
            completion(error)
        }
    }

    // MARK: - Fetch profile for any uid
    func fetchProfile(uid: String, completion: @escaping (UserProfile?, Error?) -> Void) {
        userDocument(uid: uid).getDocument(as: UserProfile.self) { result in
            switch result {
            case .success(let profile):
                completion(profile, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    // MARK: - Update specific fields
    func updateProfile(uid: String, fields: [String: Any], completion: ((Error?) -> Void)? = nil) {
        userDocument(uid: uid).updateData(fields, completion: completion)
    }

    // MARK: - Listen to real-time profile updates
    func listenToProfile(uid: String, onChange: @escaping (UserProfile?) -> Void) -> ListenerRegistration {
        userDocument(uid: uid).addSnapshotListener { snapshot, _ in
            let profile = try? snapshot?.data(as: UserProfile.self)
            onChange(profile)
        }
    }
}
