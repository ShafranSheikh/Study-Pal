import SwiftUI


struct AddGradeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GradeViewModel

    // Form fields
    @State private var subject = ""
    @State private var category = "Assignment"
    @State private var name = ""
    @State private var score = ""
    @State private var maxScore = ""
    @State private var target = ""
    @State private var date = ""
    @State private var selectedColor: Color = .blue

    // UI state
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    let categories = ["Assignment", "Exam", "Quiz", "Project"]

    let colorOptions: [(name: String, color: Color)] = [
        ("Blue",   .blue),
        ("Green",  .green),
        ("Purple", .purple),
        ("Red",    .red),
        ("Orange", .orange),
        ("Teal",   .teal)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.title2.bold())
                    .foregroundColor(.black)
            }

            Text("Add Grade")
                .font(.system(size: 34, weight: .bold))

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {

                    // Subject
                    fieldLabel("Subject")
                    TextField("eg: Mathematics", text: $subject)
                        .fieldStyle()

                    // Category picker
                    fieldLabel("Category")
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray5).opacity(0.5))
                    .cornerRadius(12)

                    // Name / event
                    fieldLabel("Name")
                    TextField("eg: Midterm", text: $name)
                        .fieldStyle()

                    // Score & Max Score side by side
                    HStack(spacing: 15) {
                        VStack(alignment: .leading) {
                            fieldLabel("Score")
                            TextField("e.g: 80", text: $score)
                                .fieldStyle()
                                .keyboardType(.decimalPad)
                        }
                        VStack(alignment: .leading) {
                            fieldLabel("Max Score")
                            TextField("e.g: 100", text: $maxScore)
                                .fieldStyle()
                                .keyboardType(.decimalPad)
                        }
                    }

                    // Target
                    fieldLabel("Target (%)")
                    TextField("e.g: 85", text: $target)
                        .fieldStyle()
                        .keyboardType(.decimalPad)

                    // Date
                    fieldLabel("Date")
                    TextField("dd-MM-yyyy", text: $date)
                        .fieldStyle()

                    // Subject colour
                    fieldLabel("Subject Colour")
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.name) { option in
                            Circle()
                                .fill(option.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == option.color ? 3 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(option.color, lineWidth: selectedColor == option.color ? 2 : 0)
                                        .padding(-3)
                                )
                                .onTapGesture { selectedColor = option.color }
                        }
                    }

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            // Actions
            VStack(spacing: 15) {
                Button { saveGrade() } label: {
                    HStack {
                        if isSaving {
                            ProgressView().tint(.white).padding(.trailing, 4)
                        }
                        Text(isSaving ? "Saving…" : "Add Grade")
                    }
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? Color.blue : Color.blue.opacity(0.4))
                    .cornerRadius(30)
                }
                .disabled(!canSave || isSaving)

                Button("Cancel") { dismiss() }
                    .foregroundColor(.black)
            }
        }
        .padding(25)
        .navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemBackground))
    }

    private var canSave: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(score) != nil &&
        (Double(maxScore) ?? 0) > 0
    }

    private func saveGrade() {
        guard let scoreVal = Double(score),
              let maxVal   = Double(maxScore),
              maxVal > 0 else { return }

        isSaving = true
        errorMessage = nil

        let entry = GradeEntry(
            subject:   subject.trimmingCharacters(in: .whitespaces),
            name:      name.trimmingCharacters(in: .whitespaces),
            category:  category,
            score:     scoreVal,
            maxScore:  maxVal,
            target:    Double(target) ?? 0,
            date:      date.trimmingCharacters(in: .whitespaces),
            colorHex:  selectedColor.toHex() ?? "#0000FF"
        )

        viewModel.addGrade(entry) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    dismiss()
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text).bold()
    }
}

private extension View {
    func fieldStyle() -> some View {
        self
            .padding()
            .background(Color(UIColor.systemGray5).opacity(0.5))
            .cornerRadius(12)
    }
}
