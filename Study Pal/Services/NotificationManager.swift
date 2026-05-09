import Foundation
import Combine
import UserNotifications
import SwiftUI


class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    @Published var notifications: [AppNotification] = []
    
    private let notificationsKey = "app_notifications_key"
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
        loadNotifications()
    }
    
    //In-App Notification Management
    
    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: notificationsKey),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            self.notifications = decoded.sorted(by: { $0.date > $1.date })
        }
    }
    
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: notificationsKey)
        }
    }
    
    func addInAppNotification(title: String, body: String) {
        let newNotification = AppNotification(title: title, body: body)
        DispatchQueue.main.async {
            self.notifications.insert(newNotification, at: 0)
            self.saveNotifications()
        }
    }
    
    func markAllAsRead() {
        DispatchQueue.main.async {
            for i in 0..<self.notifications.count {
                self.notifications[i].isRead = true
            }
            self.saveNotifications()
        }
    }
    
    func clearAll() {
        DispatchQueue.main.async {
            self.notifications.removeAll()
            self.saveNotifications()
        }
    }
    
    func removeNotifications(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.notifications.remove(atOffsets: offsets)
            self.saveNotifications()
        }
    }
    
    //Permission Handling
    
    /// Request notification permission from the user.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check the current authorization status.
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Task Creation Notification
    
    /// Send a local push notification confirming a task was created.
    func sendTaskCreatedNotification(title: String, subject: String, dueDate: String, priority: String) {
        let content = UNMutableNotificationContent()
        content.title = "📝 New Task Created"
        let body = buildTaskNotificationBody(title: title, subject: subject, dueDate: dueDate, priority: priority)
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "TASK_CREATED"
        

        addInAppNotification(title: content.title, body: body)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task-created-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling task creation notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Game Notifications
    
    /// Send a notification when a user wins a game.
    func sendGameWinNotification(gameName: String, score: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Victory!"
        let body = "Amazing! You won in \(gameName) with a score of \(score)!"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "GAME_WIN"
        
        addInAppNotification(title: content.title, body: body)
        scheduleNotification(content: content)
    }

    /// Send a notification when a user loses a game.
    func sendGameLossNotification(gameName: String, score: Int) {
        let content = UNMutableNotificationContent()
        content.title = " Game Over"
        let body = "Better luck next time! You scored \(score) in \(gameName). Keep practicing!"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "GAME_LOSS"
        
        addInAppNotification(title: content.title, body: body)
        scheduleNotification(content: content)
    }

    /// Send a notification when a high score is set.
    func sendHighScoreNotification(gameName: String, score: Int) {
        let content = UNMutableNotificationContent()
        content.title = "New High Score!"
        let body = "Incredible! You set a new record of \(score) in \(gameName)!"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "HIGH_SCORE"
        
        addInAppNotification(title: content.title, body: body)
        scheduleNotification(content: content)
    }

    /// Send a notification when a grade is successfully created.
    func sendGradeCreatedNotification(subject: String, name: String, score: Double, maxScore: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🎓 Grade Added"
        let percentage = maxScore > 0 ? (score / maxScore) * 100 : 0
        let body = "You've added a new grade for \(subject): \(name). Score: \(Int(score))/\(Int(maxScore)) (\(Int(percentage))%)"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "GRADE_CREATED"
        
        addInAppNotification(title: content.title, body: body)
        scheduleNotification(content: content)
    }

    private func scheduleNotification(content: UNMutableNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    //Helpers
    
    private func buildTaskNotificationBody(title: String, subject: String, dueDate: String, priority: String) -> String {
        var body = "\"\(title)\""
        
        if !subject.isEmpty {
            body += " in \(subject)"
        }
        
        body += " has been added to your study plan."
        
        if !dueDate.isEmpty {
            body += " Due: \(dueDate)."
        }
        
        body += " Priority: \(priority)."
        
        return body
    }
    
    
    /// Show notifications even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap actions.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
