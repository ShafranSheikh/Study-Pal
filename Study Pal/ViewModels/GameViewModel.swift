import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// GameViewModel
class GameViewModel: ObservableObject {

    // Published State
    @Published var highScores: [String: Int] = [:]  
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    init() {
        fetchHighScores()
    }

    // Game Type Constants
    static let memoryMatch = "memoryMatch"
    static let speedClick  = "speedClick"
    static let mathRush    = "mathRush"
    static let colorMatch  = "colorMatch"

    // Save Result
    
    func saveResult(_ result: GameResult, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("⚠️ GameViewModel.saveResult: No authenticated user — skipping save.")
            completion?(NSError(
                domain: "GameViewModel",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
            return
        }

        isSaving = true

        db.collection("users")
            .document(uid)
            .collection("gameResults")
            .addDocument(data: result.firestoreData) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isSaving = false

                    if let error = error {
                        print(" GameViewModel.saveResult: Firestore write failed — \(error.localizedDescription)")
                        self?.errorMessage = "Could not save result: \(error.localizedDescription)"
                        completion?(error)
                        return
                    }

                    print(" GameViewModel.saveResult: Result saved for \(result.gameType) — score: \(result.score)")

                    
                    let xpToAward = max(25, (result.score / 10) * 5)
                    UserService.shared.addXP(uid: uid, amount: xpToAward) { xpError in
                        if let xpError = xpError {
                            print(" GameViewModel: XP award failed — \(xpError.localizedDescription)")
                        } else {
                            print("GameViewModel: +\(xpToAward) XP awarded to \(uid)")
                        }
                    }

                    // Refresh high scores cache and check for new high score
                    let oldHighScore = self?.highScores[result.gameType] ?? 0
                    if result.score > oldHighScore {
                        NotificationManager.shared.sendHighScoreNotification(
                            gameName: self?.formatGameName(result.gameType) ?? result.gameType,
                            score: result.score
                        )
                    }
                    
                    self?.fetchHighScores()
                    completion?(nil)
                }
            }
    }

    private func formatGameName(_ type: String) -> String {
        switch type {
        case GameViewModel.memoryMatch: return "Memory Match"
        case GameViewModel.speedClick: return "Speed Click"
        case GameViewModel.mathRush: return "Math Rush"
        case GameViewModel.colorMatch: return "Color Match"
        default: return type.capitalized
        }
    }

    // Fetch High Scores
    
    func fetchHighScores() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("GameViewModel.fetchHighScores: No authenticated user.")
            return
        }

        db.collection("users")
            .document(uid)
            .collection("gameResults")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print(" GameViewModel.fetchHighScores: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var best: [String: Int] = [:]
                for doc in documents {
                    if let gameType = doc.data()["gameType"] as? String,
                       let score = doc.data()["score"] as? Int {
                        best[gameType] = max(best[gameType] ?? 0, score)
                    }
                }

                DispatchQueue.main.async {
                    self?.highScores = best
                    print(" GameViewModel.fetchHighScores: \(best)")
                }
            }
    }
}
