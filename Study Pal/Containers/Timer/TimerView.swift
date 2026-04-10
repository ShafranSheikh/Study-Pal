import SwiftUI

struct TimerView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showCompleteAlert = false
    
    var availableTasks: [StudyTask] {
        taskViewModel.tasks.filter { $0.status == "In Progress" || $0.status == "To Do" }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Using your specific background color
            Color.gray.opacity(0.09)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header Section
                    HStack {
                        Text("Focus Timer")
                            .font(.system(size: 28, weight: .bold))
                        Spacer()
                        
                        
                        NavigationLink(destination: FocusInsightsView()) {
                            HStack(spacing: 4) {
                                Text("Insights")
                                Image(systemName: "sparkles")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Timer Mode Selection
                    HStack(spacing: 12) {
                        TimerModeCard(title: "Focus", time: "25 Min", isSelected: timerViewModel.selectedMode == "Focus")
                            .onTapGesture { timerViewModel.selectMode("Focus") }
                        TimerModeCard(title: "Short", time: "5 Min", isSelected: timerViewModel.selectedMode == "Short")
                            .onTapGesture { timerViewModel.selectMode("Short") }
                        TimerModeCard(title: "Long", time: "15 Min", isSelected: timerViewModel.selectedMode == "Long")
                            .onTapGesture { timerViewModel.selectMode("Long") }
                    }
                    .padding(.horizontal)
                    
                    // Study Task Picker
                    Menu {
                        Picker("Select a task", selection: $timerViewModel.selectedTaskId) {
                            Text("No task selected").tag("")
                            ForEach(availableTasks) { task in
                                Text(task.title).tag(task.id ?? "")
                            }
                        }
                    } label: {
                        HStack {
                            Text(timerViewModel.selectedTaskId.isEmpty ? "Select an active task" : (availableTasks.first(where: { $0.id == timerViewModel.selectedTaskId })?.title ?? "Unknown Task"))
                            .foregroundColor(timerViewModel.selectedTaskId.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Main Timer Card
                    VStack(spacing: 35) {
                        Text(timerViewModel.timeString)
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    
                                Capsule()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geometry.size.width * CGFloat(timerViewModel.progress), height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 40)
                        
                        // Control Buttons
                        HStack(spacing: 40) {
                            ControlButton(icon: timerViewModel.isRunning ? "pause.fill" : "play.fill", colors: [.blue, .purple]) {
                                timerViewModel.toggleTimer()
                            }
                            ControlButton(icon: "checkmark", colors: [.green, .mint]) {
                                if !timerViewModel.selectedTaskId.isEmpty {
                                    showCompleteAlert = true
                                } else {
                                    timerViewModel.finishSessionEarly()
                                }
                            }
                            ControlButton(icon: "arrow.counterclockwise", colors: [.indigo, .purple]) {
                                timerViewModel.resetTimer()
                            }
                        }
                        .disabled(timerViewModel.selectedTaskId.isEmpty)
                        .opacity(timerViewModel.selectedTaskId.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.vertical, 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(35)
                    .padding(.horizontal)
                    
                    // Pro Tips Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Pro Tips")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            TipItem(text: "Put your phone in another room to minimize distractions")
                            TipItem(text: "Take a 5-minute walk during your short breaks")
                        }
                    }
                    .padding(25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .alert("Complete Task?", isPresented: $showCompleteAlert) {
            Button("Just finish session", role: .none) {
                timerViewModel.finishSessionEarly(markAsDone: false)
            }
            Button("Mark Task as Done", role: .destructive) {
                timerViewModel.finishSessionEarly(markAsDone: true)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to mark this task as complete or just save this study session?")
        }
        }
    }
}

// MARK: - Subcomponents

struct TimerModeCard: View {
    let title: String
    let time: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
            Text(time)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(
            isSelected ?
            AnyView(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)) :
            AnyView(Color.white)
        )
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
        .shadow(color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.03), radius: 8, y: 4)
    }
}

struct ControlButton: View {
    let icon: String
    let colors: [Color]
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 65, height: 65)
                .background(Circle().fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)))
                .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, y: 5)
        }
    }
}

struct TipItem: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
            Text(text)
                .font(.footnote)
                .lineSpacing(4)
        }
    }
}

#Preview {
    TimerView()
}
