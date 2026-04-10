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

    // MARK: - Add XP and update Level
    func addXP(uid: String, amount: Int, completion: ((Error?) -> Void)? = nil) {
        fetchProfile(uid: uid) { profile, error in
            guard let profile = profile else {
                completion?(error)
                return
            }
            
            let newXP = profile.xp + amount
            let newLevel = Level.calculateLevel(from: newXP)
            
            let updates: [String: Any] = [
                "xp": newXP,
                "level": newLevel
            ]
            
            self.updateProfile(uid: uid, fields: updates, completion: completion)
        }
    }

    // MARK: - Update Streak
    func updateStreak(uid: String, completion: ((Error?) -> Void)? = nil) {
        fetchProfile(uid: uid) { profile, error in
            guard let profile = profile else {
                completion?(error)
                return
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var newStreak = (profile.currentStreak ?? 0)
            
            if let lastUpdate = profile.lastStreakUpdate {
                let lastUpdateDate = calendar.startOfDay(for: lastUpdate)
                
                if lastUpdateDate == today {
                    // Already updated today
                    completion?(nil)
                    return
                } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                          lastUpdateDate == yesterday {
                    // Last update was yesterday, increment streak
                    newStreak += 1
                } else {
                    // Last update was more than a day ago, reset to 1
                    newStreak = 1
                }
            } else {
                // First time update
                newStreak = 1
            }

            let updates: [String: Any] = [
                "currentStreak": newStreak,
                "lastStreakUpdate": Timestamp(date: Date())
            ]

            self.updateProfile(uid: uid, fields: updates, completion: completion)
        }
    }

    // MARK: - Check and Reset Streak if missed
    func checkStreakReset(uid: String) {
        fetchProfile(uid: uid) { profile, error in
            guard let profile = profile, let lastUpdate = profile.lastStreakUpdate else { return }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastUpdateDate = calendar.startOfDay(for: lastUpdate)

            if let diff = calendar.dateComponents([.day], from: lastUpdateDate, to: today).day, diff > 1 {
                // More than 1 day difference, streak is broken
                self.updateProfile(uid: uid, fields: ["currentStreak": 0])
            }
        }
    }
}
