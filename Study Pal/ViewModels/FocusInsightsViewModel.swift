import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class FocusInsightsViewModel: ObservableObject {
    @Published var sessions: [FocusSession] = []
    @Published var totalFocusTime: String = "0h 0m"
    @Published var averageFocusScore: String = "0/10"
    @Published var peakTime: String = "N/A"
    @Published var recentSessions: [FocusSession] = []
    
    // Pattern Data
    @Published var weeklyPattern: [Double] = Array(repeating: 0, count: 7)
    @Published var timeOfDayPattern: [Double] = Array(repeating: 0, count: 4)
    @Published var subjectDistribution: [String: Int] = [:]
    
    private var db = Firestore.firestore()
    private var taskMap: [String: (title: String, subject: String)] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else { 
            print(" FocusInsightsViewModel: No user logged in")
            return 
        }
        
        // Fetch tasks and sessions independently
        fetchTasks(uid: uid)
        fetchSessions(uid: uid)
    }
    
    private func fetchTasks(uid: String) {
        db.collection("users").document(uid).collection("tasks").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("FocusInsightsViewModel: Error fetching tasks: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = querySnapshot {
                var newMap: [String: (title: String, subject: String)] = [:]
                for document in snapshot.documents {
                    let data = document.data()
                    let title = data["title"] as? String ?? "Unknown"
                    let subject = data["subject"] as? String ?? "General"
                    newMap[document.documentID] = (title, subject)
                }
                self?.taskMap = newMap
                self?.processInsights()
            }
        }
    }
    
    private func fetchSessions(uid: String) {
        print("📊 FocusInsightsViewModel: Starting listener for timer_records")
        db.collection("users").document(uid).collection("timer_records")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("❌ FocusInsightsViewModel: Firestore Error: \(error.localizedDescription)")
                    return
                }
                
                guard let self = self, let snapshot = querySnapshot else { return }
                
                print("📝 FocusInsightsViewModel: Received \(snapshot.documents.count) records")
                
                var newSessions: [FocusSession] = []
                for document in snapshot.documents {
                    let data = document.data()
                    
                    // More robust number parsing
                    let duration: Int
                    if let d = data["duration"] as? Int {
                        duration = d
                    } else if let d = data["duration"] as? Double {
                        duration = Int(d)
                    } else if let d = data["duration"] as? Int64 {
                        duration = Int(d)
                    } else {
                        duration = 0
                    }
                    
                    let mode = data["mode"] as? String ?? "Focus"
                    let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                    let date = timestamp.dateValue()
                    let taskId = data["taskId"] as? String
                    
                    newSessions.append(FocusSession(id: document.documentID, duration: duration, mode: mode, date: date, taskId: taskId))
                }
                
                print("✅ FocusInsightsViewModel: Parsed \(newSessions.count) sessions")
                
                DispatchQueue.main.async {
                    self.sessions = newSessions
                    self.processInsights()
                }
            }
    }
    
    private func processInsights() {
        print("processing insights for \(sessions.count) sessions...")
        // Apply task titles to sessions
        let processedSessions = sessions.map { session -> FocusSession in
            var updated = session
            if let taskId = session.taskId, let taskInfo = taskMap[taskId] {
                updated.taskTitle = taskInfo.title
                updated.subject = taskInfo.subject
            }
            return updated
        }
        
        let focusSessions = processedSessions.filter { $0.mode == "Focus" }
        print("🎯 Found \(focusSessions.count) Focus sessions out of \(sessions.count) total")
        
        // 1. Total Focus Time
        let totalSeconds = focusSessions.reduce(0) { $0 + $1.duration }
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        self.totalFocusTime = "\(hours)h \(minutes)m"
        
        // 2. Average Focus Score
        if !focusSessions.isEmpty {
            let avgDuration = Double(totalSeconds) / Double(focusSessions.count)
            let score = min(10, Int((avgDuration / 1500.0) * 10))
            self.averageFocusScore = "\(score)/10"
        } else {
            self.averageFocusScore = "0/10"
        }
        
        // 3. Recent Sessions
        self.recentSessions = Array(focusSessions.prefix(5))
        
        // 4. Update Patterns
        updatePatterns(focusSessions: focusSessions)
    }
    
    private func updatePatterns(focusSessions: [FocusSession]) {
        let calendar = Calendar.current
        let now = Date()
        
        // Weekly Pattern
        var weeklyData = Array(repeating: 0.0, count: 7)
        for session in focusSessions {
            let components = calendar.dateComponents([.day], from: session.date, to: now)
            if let dayDiff = components.day, dayDiff < 7 {
                let weekday = calendar.component(.weekday, from: session.date)
                let index = (weekday + 5) % 7 // Mon=0
                weeklyData[index] += Double(session.duration) / 60.0
            }
        }
        self.weeklyPattern = weeklyData
        
        // Time of Day
        var timeOfDay = Array(repeating: 0.0, count: 4)
        for session in focusSessions {
            let hour = calendar.component(.hour, from: session.date)
            switch hour {
            case 5..<12: timeOfDay[0] += 1
            case 12..<17: timeOfDay[1] += 1
            case 17..<21: timeOfDay[2] += 1
            default: timeOfDay[3] += 1
            }
        }
        self.timeOfDayPattern = timeOfDay
        
        let labels = ["Morning", "Afternoon", "Evening", "Night"]
        if let peakIndex = timeOfDay.enumerated().max(by: { $0.element < $1.element }), peakIndex.element > 0 {
            self.peakTime = labels[peakIndex.offset]
        } else {
            self.peakTime = "N/A"
        }
        
        // Subject Distribution
        var subjects: [String: Int] = [:]
        for session in focusSessions {
            let sub = session.subject ?? "General"
            subjects[sub, default: 0] += session.duration
        }
        self.subjectDistribution = subjects
    }
}
