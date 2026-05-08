import Foundation
import FirebaseFirestore

struct StudyTask: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var subject: String
    var taskType: String
    var dueDate: String
    var priority: String
    var status: String
    var timeSpent: Int = 0 
    var breakTimeSpent: Int = 0 
}
