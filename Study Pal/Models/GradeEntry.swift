import Foundation
import FirebaseFirestore

// MARK: - GradeEntry Model
/// Represents a single graded assessment (exam, quiz, assignment, etc.)
/// Path: users/{uid}/grades/{entryId}
struct GradeEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var subject: String       // e.g. "Mathematics"
    var name: String          // e.g. "Midterm"
    var category: String      // "Assignment" | "Exam" | "Quiz" | "Project"
    var score: Double         // raw marks earned,  e.g. 82.5
    var maxScore: Double      // maximum possible,  e.g. 100
    var target: Double        // target percentage  e.g. 90  (stored as %, not ratio)
    var date: String          // display string "dd-MM-yyyy"
    var colorHex: String      // hex string so Color survives Firestore round-trips
    var createdAt: Date?

    /// Percentage this entry achieved (0–100)
    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore) * 100
    }

    /// Ratio (0–1) for SwiftUI ProgressView
    var ratio: Double { percentage / 100 }

    init(
        subject: String,
        name: String,
        category: String,
        score: Double,
        maxScore: Double,
        target: Double,
        date: String,
        colorHex: String
    ) {
        self.subject = subject
        self.name = name
        self.category = category
        self.score = score
        self.maxScore = maxScore
        self.target = target
        self.date = date
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
