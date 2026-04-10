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
    var status: String // e.g., "To Do", "In Progress", "Done"
    var timeSpent: Int = 0 // Cumulative study time in seconds
    var breakTimeSpent: Int = 0 // Cumulative break time in seconds
}
