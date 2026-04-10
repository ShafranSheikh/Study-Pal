import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [StudyTask] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchTasks()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchTasks() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listenerRegistration = db.collection("users").document(uid).collection("tasks")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.tasks = documents.compactMap { document in
                    var task = try? document.data(as: StudyTask.self)
                    task?.id = document.documentID
                    return task
                }
            }
    }
    
    func addTask(title: String, description: String, subject: String, taskType: String, dueDate: String, priority: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("users").document(uid).collection("tasks").document()
        let newTask = StudyTask(
            id: docRef.documentID,
            title: title,
            description: description,
            subject: subject,
            taskType: taskType,
            dueDate: dueDate,
            priority: priority,
            status: "To Do",
            timeSpent: 0,
            breakTimeSpent: 0
        )
        
        do {
            try docRef.setData(from: newTask)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    func updateTaskStatus(task: StudyTask, newStatus: String) {
        guard let uid = Auth.auth().currentUser?.uid, let taskId = task.id else { return }
        
        db.collection("users").document(uid).collection("tasks").document(taskId)
            .updateData(["status": newStatus]) { error in
                if let error = error {
                    print("Error updating task status: \(error.localizedDescription)")
                } else if newStatus == "Done" {
                    // Add 200 XP and update streak when task is completed
                    UserService.shared.addXP(uid: uid, amount: 200)
                    UserService.shared.updateStreak(uid: uid)
                }
            }
    }
}
