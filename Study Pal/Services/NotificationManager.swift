import Foundation
import Combine
import UserNotifications

/// Singleton manager for scheduling and handling local push notifications.
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Handling
    
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
    
    // MARK: - Task Creation Notification
    
    /// Send a local push notification confirming a task was created.
    /// - Parameters:
    ///   - title: The task title
    ///   - subject: The task subject
    ///   - dueDate: The due date string (may be empty)
    ///   - priority: The task priority
    func sendTaskCreatedNotification(title: String, subject: String, dueDate: String, priority: String) {
        let content = UNMutableNotificationContent()
        content.title = "📝 New Task Created"
        content.body = buildTaskNotificationBody(title: title, subject: subject, dueDate: dueDate, priority: priority)
        content.sound = .default
        content.categoryIdentifier = "TASK_CREATED"
        
        // Fire after a 1-second delay so the user sees it as a push notification
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
    
    // MARK: - Helpers
    
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
    
    // MARK: - UNUserNotificationCenterDelegate
    
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
        // Future: navigate to task detail when tapped
        completionHandler()
    }
}
