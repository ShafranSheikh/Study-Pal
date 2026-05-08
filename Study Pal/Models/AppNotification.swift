import Foundation

struct AppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), title: String, body: String, date: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.isRead = isRead
    }
}
