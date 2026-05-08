import Foundation
import FirebaseFirestore
struct GradeEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var subject: String       
    var name: String         
    var category: String      
    var score: Double        
    var maxScore: Double      
    var target: Double        
    var date: String         
    var colorHex: String     
    var createdAt: Date?


    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore) * 100
    }


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
