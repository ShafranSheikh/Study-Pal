import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()

    private init() {}


    private func userDocument(uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }


    func createProfile(_ profile: UserProfile, completion: @escaping (Error?) -> Void) {
        do {
            try userDocument(uid: profile.id).setData(from: profile, completion: completion)
        } catch {
            completion(error)
        }
    }


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

    // Update specific fields
    func updateProfile(uid: String, fields: [String: Any], completion: ((Error?) -> Void)? = nil) {
        userDocument(uid: uid).updateData(fields, completion: completion)
    }

    // Listen to real-time profile updates
    func listenToProfile(uid: String, onChange: @escaping (UserProfile?) -> Void) -> ListenerRegistration {
        userDocument(uid: uid).addSnapshotListener { snapshot, _ in
            let profile = try? snapshot?.data(as: UserProfile.self)
            onChange(profile)
        }
    }

    // Add XP and update Level
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

    // Update Streak
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
                    
                    completion?(nil)
                    return
                } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                          lastUpdateDate == yesterday {
                    
                    newStreak += 1
                } else {
                    
                    newStreak = 1
                }
            } else {
               
                newStreak = 1
            }

            let updates: [String: Any] = [
                "currentStreak": newStreak,
                "lastStreakUpdate": Timestamp(date: Date())
            ]

            self.updateProfile(uid: uid, fields: updates, completion: completion)
        }
    }

    //Check and Reset Streak if missed
    func checkStreakReset(uid: String) {
        fetchProfile(uid: uid) { profile, error in
            guard let profile = profile, let lastUpdate = profile.lastStreakUpdate else { return }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastUpdateDate = calendar.startOfDay(for: lastUpdate)

            if let diff = calendar.dateComponents([.day], from: lastUpdateDate, to: today).day, diff > 1 {
                self.updateProfile(uid: uid, fields: ["currentStreak": 0])
            }
        }
    }
}
