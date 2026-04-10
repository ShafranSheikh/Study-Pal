import SwiftUI

// Removed local Task model to use StudyTask from Models

struct TasksView: View {
    @State private var searchText = ""
    @State private var selectedTab = "To Do"
    @StateObject private var viewModel = TaskViewModel()
    
    var filteredTasks: [StudyTask] {
        let statusFiltered = viewModel.tasks.filter { $0.status == selectedTab }
        if searchText.isEmpty {
            return statusFiltered
        } else {
            return statusFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // HEADER SECTION
                    HStack {
                        Text("My Tasks")
                            .font(.system(size: 32, weight: .bold))
                        
                        Spacer()
                        
                        // Use NavigationLink to push AddTaskView as a new page
                        NavigationLink(destination: AddTaskView(viewModel: viewModel)) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // SEARCH BAR
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search tasks...", text: $searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // TAB SECTION
                    HStack(spacing: 12) {
                        TabButton(title: "To Do", count: viewModel.tasks.filter { $0.status == "To Do" }.count, selectedTab: $selectedTab)
                        TabButton(title: "In Progress", count: viewModel.tasks.filter { $0.status == "In Progress" }.count, selectedTab: $selectedTab)
                        TabButton(title: "Done", count: viewModel.tasks.filter { $0.status == "Done" }.count, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)

                    // TASK LIST
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredTasks) { task in
                                TaskCard(task: task) { newStatus in
                                    viewModel.updateTaskStatus(task: task, newStatus: newStatus)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
        }
    }
}

// MARK: - Subviews

struct TabButton: View {
    let title: String
    let count: Int
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = title
            }
        }) {
            Text("\(title) (\(count))")
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(.black)
                .background(selectedTab == title ? Color.white : Color.clear)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(selectedTab == title ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct TaskCard: View {
    let task: StudyTask
    var onStatusChange: (String) -> Void
    
    @State private var showingConfirmation = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: {
                if task.status != "Done" {
                    showingConfirmation = true
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(task.status == "Done" ? Color.green : (task.status == "In Progress" ? Color.blue : Color.gray.opacity(0.4)), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if task.status == "Done" {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    } else if task.status == "In Progress" {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.top, 4)
            }
            .alert(task.status == "To Do" ? "Start Task" : "Complete Task", isPresented: $showingConfirmation) {
                if task.status == "To Do" {
                    Button("Start", role: .none) { onStatusChange("In Progress") }
                } else if task.status == "In Progress" {
                    Button("Complete", role: .none) { onStatusChange("Done") }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(task.status == "To Do" ? "Are you ready to start this task?" : "Have you finished this task?")
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.plaintext")
                        .foregroundColor(.gray)
                    Text(task.title)
                        .font(.system(size: 18, weight: .bold))
                }
                
                Text(task.description)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack(spacing: 10) {
                    TagLabel(text: task.priority, color: .blue)
                    TagLabel(text: task.subject, color: .purple)
                    
                    Text("Due \(task.dueDate)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

struct TagLabel: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(color.opacity(0.8))
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}
