import AppIntents
import FirebaseAuth
import FirebaseFirestore

//App Intent: Add Task via Siri

struct AddTaskIntent: AppIntent {

    static var title: LocalizedStringResource = "Add a Study Task"
    static var description = IntentDescription("Quickly add a new task to Study Pal.")

    @Parameter(title: "Task Title", description: "The name of the task")
    var taskTitle: String

    @Parameter(title: "Subject", description: "The subject this task belongs to")
    var subject: String

    @Parameter(
        title: "Task Type",
        description: "Type of task: Assignment, Exam, Project, or Other"
    )
    var taskType: TaskTypeAppEnum

    @Parameter(
        title: "Priority",
        description: "Priority level: Low Priority, Medium Priority, or High Priority"
    )
    var priority: TaskPriorityAppEnum

    @Parameter(
        title: "Description",
        description: "Optional details about the task",
        requestValueDialog: "Would you like to add a description? Say it now, or say 'none' to skip."
    )
    var taskDescription: String?

    @Parameter(
        title: "Due Date",
        description: "When is this task due?",
        requestValueDialog: "What is the due date? Say something like December 31 2025, or say 'none' to skip."
    )
    var dueDate: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$taskTitle) for \(\.$subject)") {
            \.$taskType
            \.$priority
            \.$taskDescription
            \.$dueDate
        }
    }

    func perform() async throws -> some ProvidesDialog {
        guard let uid = Auth.auth().currentUser?.uid else {
            return .result(dialog: IntentDialog("You need to be signed in to Study Pal to add tasks."))
        }

        let rawDescription: String?
        if taskDescription == nil {
            rawDescription = try await $taskDescription.requestValue(
                "Would you like to add a description? Say it or say 'none' to skip."
            )
        } else {
            rawDescription = taskDescription
        }
        let resolvedDescription = cleanOptional(rawDescription)

        let rawDueDate: String?
        if dueDate == nil {
            rawDueDate = try await $dueDate.requestValue(
                "What is the due date? Say something like December 31 2025, or say 'none' to skip."
            )
        } else {
            rawDueDate = dueDate
        }
        let resolvedDueDate = cleanOptional(rawDueDate)

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid).collection("tasks").document()

        let taskData: [String: Any] = [
            "id": docRef.documentID,
            "title": taskTitle,
            "description": resolvedDescription,
            "subject": subject,
            "taskType": taskType.rawValue,
            "dueDate": resolvedDueDate,
            "priority": priority.rawValue,
            "status": "To Do",
            "timeSpent": 0,
            "breakTimeSpent": 0
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            docRef.setData(taskData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        let dateMsg = resolvedDueDate.isEmpty ? "" : " due on \(resolvedDueDate)"
        return .result(dialog: IntentDialog("Done! I've added '\(taskTitle)' for \(subject)\(dateMsg) to your Study Pal tasks."))
    }

    private func cleanOptional(_ value: String?) -> String {
        guard let v = value, !v.isEmpty else { return "" }
        let skip = ["none", "skip", "no", "n/a", "nope"]
        return skip.contains(v.lowercased().trimmingCharacters(in: .whitespaces)) ? "" : v
    }
}

// Enums for Task Type and Priority

enum TaskTypeAppEnum: String, AppEnum {
    case assignment = "Assignment"
    case exam = "Exam"
    case project = "Project"
    case other = "Other"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Task Type")
    static var caseDisplayRepresentations: [TaskTypeAppEnum: DisplayRepresentation] = [
        .assignment: "Assignment",
        .exam: "Exam",
        .project: "Project",
        .other: "Other"
    ]
}


enum TaskPriorityAppEnum: String, AppEnum {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority")
    static var caseDisplayRepresentations: [TaskPriorityAppEnum: DisplayRepresentation] = [
        .low: "Low Priority",
        .medium: "Medium Priority",
        .high: "High Priority"
    ]
}
