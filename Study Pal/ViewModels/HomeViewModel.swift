import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var upcomingTasks: [StudyTask] = []
    @Published var inProgressTasks: [StudyTask] = []
    @Published var completedToday: Int = 0
    @Published var focusTimeToday: Int = 0 // in minutes
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchHomeData()
    }
    
    func fetchHomeData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Listen to User Profile for Level and XP
        UserService.shared.listenToProfile(uid: uid) { [weak self] profile in
            self?.userProfile = profile
        }
        
        // Reset streak if missed
        UserService.shared.checkStreakReset(uid: uid)
        
        // Fetch Today's Focus Time from timer_records
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        db.collection("users").document(uid).collection("timer_records")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let totalSeconds = documents.reduce(0) { sum, doc in
                    let data = doc.data()
                    let duration = (data["duration"] as? NSNumber)?.intValue ?? 0
                    let mode = data["mode"] as? String ?? ""
                    return (mode == "Focus") ? sum + duration : sum
                }
                
                DispatchQueue.main.async {
                    self?.focusTimeToday = Int(ceil(Double(totalSeconds) / 60.0))
                }
            }
        
        // Fetch Tasks
        db.collection("users").document(uid).collection("tasks")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let allTasks = documents.compactMap { doc -> StudyTask? in
                    var task = try? doc.data(as: StudyTask.self)
                    task?.id = doc.documentID
                    return task
                }
                
                DispatchQueue.main.async {
                    self?.upcomingTasks = allTasks.filter { $0.status == "To Do" }.sorted(by: { $0.dueDate < $1.dueDate })
                    self?.inProgressTasks = allTasks.filter { $0.status == "In Progress" }
                    self?.completedToday = allTasks.filter { $0.status == "Done" }.count
                }
            }
    }
    
    var levelProgress: Double {
        guard let xp = userProfile?.xp else { return 0 }
        let currentLevelXP = xp % 1000
        return Double(currentLevelXP) / 1000.0
    }
    
    var completionRate: Double {
        let total = upcomingTasks.count + inProgressTasks.count + completedToday
        guard total > 0 else { return 0 }
        return Double(completedToday) / Double(total)
    }
    
    var focusScore: Int {
        // Simple logic: 12 minutes of focus = 1 point, max 10 points
        return min(10, focusTimeToday / 12)
    }
}
