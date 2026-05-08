import Foundation
import FirebaseFirestore

struct FocusSession: Identifiable, Codable {
    @DocumentID var id: String?
    var duration: Int
    var mode: String
    var date: Date
    var taskId: String?
    var taskTitle: String?
    var subject: String?
}
