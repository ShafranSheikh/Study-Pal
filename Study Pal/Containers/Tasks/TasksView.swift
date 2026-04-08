import SwiftUI

// MARK: - Task Model
struct Task: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let priority: String
    let category: String
    let dueDate: String
}

struct TasksView: View {
    @State private var searchText = ""
    @State private var selectedTab = "To Do"
    
    let tasks = [
        Task(title: "English Reading", description: "Read chapter 8 - 10 of To Kill a Mockingbird", priority: "High", category: "English", dueDate: "Mar 24"),
        Task(title: "Maths Assignment", description: "Complete exercise 5.5 and 5.6", priority: "Medium", category: "Maths", dueDate: "Mar 24")
    ]

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
                        NavigationLink(destination: AddTaskView()) {
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
                        TabButton(title: "To Do", count: 2, selectedTab: $selectedTab)
                        TabButton(title: "In Progress", count: 1, selectedTab: $selectedTab)
                        TabButton(title: "Done", count: 2, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)

                    // TASK LIST
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(tasks) { task in
                                TaskCard(task: task)
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
    let task: Task
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                .frame(width: 26, height: 26)
                .padding(.top, 4)
            
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
                    TagLabel(text: task.category, color: .purple)
                    
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
