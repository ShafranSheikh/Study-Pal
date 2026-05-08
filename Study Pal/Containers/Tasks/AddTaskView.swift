import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel

    @State private var taskTitle: String = ""
    @State private var description: String = ""
    @State private var subject: String = ""
    @State private var taskType: String = "Assignment"
    @State private var priority: String = "Low"

    // MARK: - Due Date State
    /// The actual selected date (nil = no due date chosen)
    @State private var selectedDate: Date? = nil
    /// Whether the inline calendar picker is expanded
    @State private var showDatePicker: Bool = false
    /// Temporary binding date used inside DatePicker (defaults to today)
    @State private var pickerDate: Date = Date()

    let taskTypes = ["Assignment", "Exam", "Project", "Other"]
    let priorities = ["Low", "Medium", "High"]

    // MARK: - Helpers
    private var formattedDate: String {
        guard let date = selectedDate else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        return fmt.string(from: date)
    }

    private var displayDate: String {
        guard let date = selectedDate else { return "No due date" }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium   // e.g. "9 May 2026"
        return fmt.string(from: date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top, 10)

                Text("Add Task")
                    .font(.system(size: 32, weight: .bold))

                // MARK: Form Fields
                VStack(alignment: .leading, spacing: 15) {

                    // Task Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task title").font(.headline)
                        TextField("eg: Math Assignment", text: $taskTitle)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description").font(.headline)
                        TextField("Add details about the task", text: $description, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }

                    // Subject
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subject").font(.headline)
                        TextField("eg: Mathematics", text: $subject)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                    }

                    // Task Type
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

                    // MARK: Due Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due date").font(.headline)

                        // Tappable row that toggles the calendar
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showDatePicker.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(selectedDate == nil ? .gray : .blue)
                                Text(displayDate)
                                    .foregroundColor(selectedDate == nil ? .gray : .primary)
                                Spacer()
                                // Clear button
                                if selectedDate != nil {
                                    Button(action: {
                                        withAnimation { selectedDate = nil; showDatePicker = false }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Inline calendar — appears when tapped
                        if showDatePicker {
                            VStack(spacing: 0) {
                                DatePicker(
                                    "",
                                    selection: $pickerDate,
                                    in: Date()...,          // only future dates
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: pickerDate) { newDate in
                                    selectedDate = newDate
                                }
                                .padding(.horizontal, 4)

                                // Confirm button
                                Button(action: {
                                    selectedDate = pickerDate
                                    withAnimation { showDatePicker = false }
                                }) {
                                    Text("Confirm Date")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding([.horizontal, .bottom], 12)
                            }
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(16)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                        }

                        // Optional: manual text entry hint
                        if !showDatePicker {
                            Text("Optional — tap the row above to pick from the calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Priority
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

                // MARK: Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        viewModel.addTask(
                            title: taskTitle,
                            description: description,
                            subject: subject,
                            taskType: taskType,
                            dueDate: formattedDate,   // "dd/MM/yyyy" or "" if not set
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

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(uiColor: .systemBackground))
    }
}

