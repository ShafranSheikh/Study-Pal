import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String          // = Firebase Auth UID
    var firstName: String
    var lastName: String
    var email: String
    var dateOfBirth: String
    var gender: String
    var avatarIcon: String
    var themeColor: String  // stored as hex string
    var level: Int
    var xp: Int
    var createdAt: Date

    var fullName: String { "\(firstName) \(lastName)" }

    // Default values for a new user
    static func defaultProfile(uid: String, firstName: String, lastName: String, email: String, dateOfBirth: String, gender: String) -> UserProfile {
        UserProfile(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dateOfBirth,
            gender: gender,
            avatarIcon: "person.fill",
            themeColor: "#007AFF",
            level: 1,
            xp: 0,
            createdAt: Date()
        )
    }
}
