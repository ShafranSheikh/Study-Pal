import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.09).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HeaderView(profile: viewModel.userProfile, progress: viewModel.levelProgress)
                        StreakCard(streak: viewModel.userProfile?.currentStreak ?? 0)
                        
                        HStack(spacing: 15) {
                            NavigationLink(destination: FlashCardsView()) {
                                ActionCard(title: "FlashCards",
                                         subtitle: "2 Remaining",
                                         icon: "bolt.fill",
                                         color: .blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: GradesView()) {
                                ActionCard(title: "Grades",
                                         subtitle: "Start studying",
                                         icon: "target",
                                         color: .indigo)
                            }
                                .buttonStyle(PlainButtonStyle())
                        }
                        
                        FocusSection(focusTime: viewModel.focusTimeToday, 
                                     completedCount: viewModel.completedToday,
                                     focusScore: viewModel.focusScore)
                        ProgressCard(completionRate: viewModel.completionRate, completed: viewModel.completedToday, remaining: viewModel.upcomingTasks.count + viewModel.inProgressTasks.count)
                        
                        if viewModel.upcomingTasks.count > 3 {
                            UrgentAlert(count: viewModel.upcomingTasks.count)
                        }
                        
                        UpcomingTasksSection(tasks: viewModel.upcomingTasks)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews

struct HeaderView: View {
    let profile: UserProfile?
    let progress: Double
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(profile?.firstName ?? "User")")
                    .font(.system(size: 28, weight: .bold))
                Text(Date().formatted(date: .complete, time: .omitted))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: 8) {
                    Text("Level \(profile?.level ?? 1)").font(.subheadline).bold()
                    Image(systemName: "bell")
                        .font(.title3)
                }
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 8)
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Capsule().fill(Color.blue).frame(width: geo.size.width * CGFloat(progress))
                        }
                    }
            }
        }
    }
}

struct StreakCard: View {
    let streak: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Study Streak").font(.headline)
                Text("\(streak) Days").font(.system(size: 34, weight: .bold))
                Text(streak > 0 ? "Keep it up! You're on fire" : "Start your streak today!")
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .opacity(0.8)
        }
        .padding()
        .foregroundColor(.white)
        .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(20)
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.white)
        .background(color)
        .cornerRadius(20)
    }
}

struct FocusSection: View {
    let focusTime: Int
    let completedCount: Int
    let focusScore: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Today's Focus").font(.title3).bold()
                Spacer()
                Text("See All").font(.caption).foregroundColor(.secondary)
            }
            
            HStack {
                FocusStat(val: "\(focusTime)M", label: "Focus Time", icon: "clock.fill", color: .purple)
                Spacer()
                FocusStat(val: "\(focusScore)/10", label: "Focus Score", icon: "scope", color: .green)
                Spacer()
                FocusStat(val: "\(completedCount)", label: "Completed", icon: "checkmark.circle.fill", color: .blue)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct FocusStat: View {
    let val: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .padding(12)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .clipShape(Circle())
            
            Text(val)
                .font(.system(size: 16, weight: .bold))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressCard: View {
    let completionRate: Double
    let completed: Int
    let remaining: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Task Progress").font(.headline)
                Spacer()
                Image(systemName: "line.3.horizontal")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Completion Rate").font(.subheadline)
                    Spacer()
                    Text("\(Int(completionRate * 100))%").font(.subheadline).bold()
                }
                ProgressView(value: completionRate)
                    .tint(.white)
                    .background(Color.white.opacity(0.3))
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(completed)").bold()
                    Text("Completed").font(.caption)
                }
                VStack(alignment: .leading) {
                    Text("\(remaining)").bold()
                    Text("Remaining").font(.caption)
                }
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(20)
    }
}

struct UrgentAlert: View {
    let count: Int
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            VStack(alignment: .leading) {
                Text("Urgent tasks").bold()
                Text("You have \(count) tasks due soon").font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

struct UpcomingTasksSection: View {
    let tasks: [StudyTask]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Tasks").font(.title3).bold()
            
            if tasks.isEmpty {
                Text("No upcoming tasks. Add some!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(tasks.prefix(3)) { task in
                    TaskRow(task: task)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TaskRow: View {
    let task: StudyTask
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "doc.plaintext")
                    Text(task.title).bold()
                }
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(task.priority).padding(.horizontal, 8).padding(.vertical, 2).background(priorityColor(task.priority).opacity(0.1)).cornerRadius(5)
                    Text(task.subject).padding(.horizontal, 8).padding(.vertical, 2).background(Color.purple.opacity(0.1)).cornerRadius(5)
                    Text("Due \(task.dueDate)").foregroundColor(.secondary)
                }
                .font(.caption2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .blue
        }
    }
}
