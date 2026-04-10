import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var taskTitle: String = ""
    @State private var description: String = ""
    @State private var subject: String = ""
    @State private var taskType: String = "Assignment"
    @State private var dueDate: String = ""
    @State private var priority: String = "Low"
    
    let taskTypes = ["Assignment", "Exam", "Project", "Other"]
    let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Navigation
                HStack {
                    Button(action: {
                        dismiss() // "Pops" the view back to TasksView
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
                Text("Add Task")
                    .font(.system(size: 32, weight: .bold))
                
                // Form Fields
                VStack(alignment: .leading, spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task title").font(.headline)
                        TextField("eg: Math Assignment", text: $taskTitle)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description").font(.headline)
                        TextField("Add details about the task", text: $description, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subject").font(.headline)
                        TextField("eg: Mathematics", text: $subject)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task type").font(.headline)
                        Menu {
                            Picker("Task type", selection: $taskType) {
                                ForEach(taskTypes, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            HStack {
                                Text(taskType).foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due date").font(.headline)
                        TextField("yyyy-mm-dd", text: $dueDate)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority").font(.headline)
                        Menu {
                            Picker("Priority", selection: $priority) {
                                ForEach(priorities, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(priority == "Low" ? .green : (priority == "Medium" ? .orange : .red))
                                    .frame(width: 15, height: 15)
                                Text(priority).foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        viewModel.addTask(
                            title: taskTitle,
                            description: description,
                            subject: subject,
                            taskType: taskType,
                            dueDate: dueDate,
                            priority: priority
                        )
                        dismiss()
                    }) {
                        Text("Add Task")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true) // Keeps the UI clean without duplicate back buttons
        .background(Color(uiColor: .systemBackground))
    }
}
