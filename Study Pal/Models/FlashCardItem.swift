import Foundation
import FirebaseFirestore

struct FlashCardItem: Identifiable, Codable {
    @DocumentID var id: String?
    var question: String
    var answer: String
    var subject: String
    var dueDate: String         
    var isAnswered: Bool        
    var createdAt: Date?

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
