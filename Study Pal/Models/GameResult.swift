import Foundation
struct GameResult {
    var gameType: String     
    var score: Int            
    var moves: Int?           
    var timeElapsed: Int?     
    var correctAnswers: Int? 
    var clicks: Int?          
    var streak: Int?          
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

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "gameType": gameType,
            "score": score,
            "playedAt": playedAt          
        ]
        if let moves = moves           { data["moves"] = moves }
        if let timeElapsed = timeElapsed { data["timeElapsed"] = timeElapsed }
        if let correctAnswers = correctAnswers { data["correctAnswers"] = correctAnswers }
        if let clicks = clicks         { data["clicks"] = clicks }
        if let streak = streak         { data["streak"] = streak }
        return data
    }
}
