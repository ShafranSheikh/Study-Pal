import Foundation
import FirebaseFirestore

// MARK: - FlashCardItem Model
/// Represents a single flash card stored in Firestore.
/// Path: users/{uid}/flashCards/{cardId}
struct FlashCardItem: Identifiable, Codable {
    @DocumentID var id: String?
    var question: String
    var answer: String
    var subject: String
    var dueDate: String         // stored as "yyyy-MM-dd" string (matches existing AddFlashCardView field)
    var isAnswered: Bool        // true once the user has viewed/submitted an answer this session
    var createdAt: Date?

    /// Convenience init for creating a new card
    init(
        question: String,
        answer: String,
        subject: String,
        dueDate: String,
        isAnswered: Bool = false
    ) {
        self.question = question
        self.answer = answer
        self.subject = subject
        self.dueDate = dueDate
        self.isAnswered = isAnswered
        self.createdAt = Date()
    }
}
