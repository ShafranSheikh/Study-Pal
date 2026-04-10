import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning = false
    @Published var selectedMode = "Focus"
    @Published var selectedTaskId: String = ""
    
    var initialDuration: Int {
        switch selectedMode {
        case "Focus": return 25 * 60
        case "Short": return 5 * 60
        case "Long": return 15 * 60
        default: return 25 * 60
        }
    }
    
    private var timer: AnyCancellable?
    private var db = Firestore.firestore()
    
    func selectMode(_ mode: String) {
        selectedMode = mode
        timeRemaining = initialDuration
        stopTimer()
    }
    
    func toggleTimer() {
        if isRunning { stopTimer() }
        else { startTimer() }
    }
    
    func startTimer() {
        guard !isRunning, timeRemaining > 0, !selectedTaskId.isEmpty else { return }
        
        // If Focus mode is selected, ensure task is set to "In Progress"
        if selectedMode == "Focus" {
            updateTaskStatus(to: "In Progress")
        }
        
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerFinished()
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = initialDuration
    }
    
    private func timerFinished() {
        stopTimer()
        let durationCompleted = initialDuration
        saveSession(taskId: selectedTaskId, duration: durationCompleted)
        timeRemaining = initialDuration
    }
    
    // Called when user clicks the checkmark button
    func finishSessionEarly(markAsDone: Bool = false) {
        let durationCompleted = initialDuration - timeRemaining
        if durationCompleted > 0 {
            saveSession(taskId: selectedTaskId, duration: durationCompleted)
        }
        
        if markAsDone && !selectedTaskId.isEmpty {
            updateTaskStatus(to: "Done")
            selectedTaskId = "" // Clear selection as task is done
        }
        
        resetTimer()
    }
    
    private func updateTaskStatus(to status: String) {
        guard let uid = Auth.auth().currentUser?.uid, !selectedTaskId.isEmpty else { return }
        db.collection("users").document(uid).collection("tasks").document(selectedTaskId)
            .updateData(["status": status]) { error in
                if let error = error {
                    print("Error updating task status: \(error.localizedDescription)")
                } else if status == "Done" {
                    // Add 200 XP and update streak when task is completed through timer
                    UserService.shared.addXP(uid: uid, amount: 200)
                    UserService.shared.updateStreak(uid: uid)
                }
            }
    }
    
    private func saveSession(taskId: String, duration: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var sessionData: [String: Any] = [
            "duration": duration,
            "mode": selectedMode,
            "date": Timestamp(date: Date())
        ]
        
        if !taskId.isEmpty {
            sessionData["taskId"] = taskId
        }
        
        // 1. Save the individual session record
        db.collection("users").document(uid).collection("timer_records").addDocument(data: sessionData) { error in
            if let error = error {
                print("Error saving session: \(error.localizedDescription)")
            } else {
                print("Successfully saved timer session")
            }
        }
        
        // 2. Update task metrics (Focus = study time, Break = break time)
        if !taskId.isEmpty {
            let taskRef = db.collection("users").document(uid).collection("tasks").document(taskId)
            let fieldToUpdate = (selectedMode == "Focus") ? "timeSpent" : "breakTimeSpent"
            
            taskRef.updateData([
                fieldToUpdate: FieldValue.increment(Int64(duration))
            ]) { error in
                if let error = error {
                    print("Error updating task metrics: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d : %02d", minutes, seconds)
    }
    
    var progress: Double {
        return 1.0 - (Double(timeRemaining) / Double(initialDuration))
    }
}
