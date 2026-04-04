import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack { // Added NavigationStack to enable screen transitions
            ZStack {
                Color.gray.opacity(0.09).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HeaderView()
                        StreakCard()
                        
                        HStack(spacing: 15) {
                            // Link to your FlashCardsView page
                            NavigationLink(destination: FlashCardsView()) {
                                ActionCard(title: "FlashCards",
                                        subtitle: "2 Remaining",
                                        icon: "bolt.fill",
                                        color: .blue)
                            }
                            .buttonStyle(PlainButtonStyle()) // Prevents default blue text color
                            
                            // Navigate to Grades
                            NavigationLink(destination: GradesView()) {
                                ActionCard(title: "Grades",
                                        subtitle: "Start studying",
                                        icon: "target",
                                        color: .indigo)
                            }
                                .buttonStyle(PlainButtonStyle())
                        }
                        
                        FocusSection()
                        ProgressCard()
                        UrgentAlert()
                        UpcomingTasksSection()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true) // Hides the top bar to keep your custom header look
        }
    }
}

// MARK: - Subviews

struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, Jhon")
                    .font(.system(size: 28, weight: .bold))
                Text("Wednesday, 25th March")
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: 8) {
                    Text("Level 1").font(.subheadline).bold()
                    Image(systemName: "bell")
                        .font(.title3)
                }
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 8)
                    .overlay(alignment: .leading) {
                        Capsule().fill(Color.gray).frame(width: 30)
                    }
            }
        }
    }
}

struct StreakCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Study Streak").font(.headline)
                Text("5 Days").font(.system(size: 34, weight: .bold))
                Text("Keep it up! You're on fire").font(.subheadline)
            }
            Spacer()
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .opacity(0.5)
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
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Today's Focus").font(.title3).bold()
                Spacer()
                Text("See All").font(.caption).foregroundColor(.secondary)
            }
            
            HStack {
                FocusStat(val: "0M", label: "Focus Time", icon: "clock.fill", color: .purple)
                Spacer()
                FocusStat(val: "7/10", label: "Focus Score", icon: "scope", color: .green)
                Spacer()
                FocusStat(val: "1", label: "Completed", icon: "checkmark.circle.fill", color: .blue)
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
                    Text("20%").font(.subheadline).bold()
                }
                ProgressView(value: 0.2)
                    .tint(.white)
                    .background(Color.white.opacity(0.3))
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("1").bold()
                    Text("Completed").font(.caption)
                }
                VStack(alignment: .leading) {
                    Text("4").bold()
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
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            VStack(alignment: .leading) {
                Text("Urgent tasks").bold()
                Text("You have 3 tasks due soon").font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

struct UpcomingTasksSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Tasks").font(.title3).bold()
            
            TaskRow(title: "English Reading", desc: "Read chapter 8 - 10", tag: "English", tagColor: .purple, due: "Mar 24")
            TaskRow(title: "Maths Assignment", desc: "Complete exercise 5.5", tag: "Maths", tagColor: .orange, due: "Mar 24")
        }
    }
}

struct TaskRow: View {
    let title: String; let desc: String; let tag: String; let tagColor: Color; let due: String
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "doc.plaintext")
                    Text(title).bold()
                }
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("High").padding(.horizontal, 8).padding(.vertical, 2).background(Color.blue.opacity(0.1)).cornerRadius(5)
                    Text(tag).padding(.horizontal, 8).padding(.vertical, 2).background(tagColor.opacity(0.1)).cornerRadius(5)
                    Text("Due \(due)").foregroundColor(.secondary)
                }
                .font(.caption2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}
