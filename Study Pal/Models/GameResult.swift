import Foundation

// MARK: - GameResult Model
/// Represents a completed game session.
/// Stored in Firestore as a dictionary to avoid Codable/Timestamp encoding issues.
/// Path: users/{uid}/gameResults/{autoId}
struct GameResult {
    var gameType: String      // "memoryMatch", "speedClick", "mathRush", "colorMatch"
    var score: Int            // Primary score for leaderboard
    var moves: Int?           // Memory Match: move count
    var timeElapsed: Int?     // Memory Match: seconds taken
    var correctAnswers: Int?  // Math Rush / Color Match
    var clicks: Int?          // Speed Click
    var streak: Int?          // Math Rush best streak
    let playedAt: Date

    init(
        gameType: String,
        score: Int,
        moves: Int? = nil,
        timeElapsed: Int? = nil,
        correctAnswers: Int? = nil,
        clicks: Int? = nil,
        streak: Int? = nil
    ) {
        self.gameType = gameType
        self.score = score
        self.moves = moves
        self.timeElapsed = timeElapsed
        self.correctAnswers = correctAnswers
        self.clicks = clicks
        self.streak = streak
        self.playedAt = Date()
    }

    // MARK: - Firestore Dictionary
    /// Converts the model into a plain [String: Any] dictionary safe for Firestore addDocument(data:).
    /// Date is stored as a Timestamp so Firestore can index and sort by it.
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "gameType": gameType,
            "score": score,
            "playedAt": playedAt          // Firestore SDK auto-converts Date → Timestamp
        ]
        if let moves = moves           { data["moves"] = moves }
        if let timeElapsed = timeElapsed { data["timeElapsed"] = timeElapsed }
        if let correctAnswers = correctAnswers { data["correctAnswers"] = correctAnswers }
        if let clicks = clicks         { data["clicks"] = clicks }
        if let streak = streak         { data["streak"] = streak }
        return data
    }
}
