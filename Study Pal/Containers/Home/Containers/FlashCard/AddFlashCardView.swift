import SwiftUI

// MARK: - AddFlashCardView
/// Form to create a new flash card and persist it to Firestore via FlashCardViewModel.
struct AddFlashCardView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FlashCardViewModel

    @State private var question = ""
    @State private var subject = ""
    @State private var dueDate = ""
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {

            // Back Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.title2.bold())
            }

            Text("Create Flash Card")
                .font(.system(size: 34, weight: .bold))

            // Question Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Question")
                    .font(.headline)
                TextEditor(text: $question)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(UIColor.systemGray5).opacity(0.5))
                    .cornerRadius(12)
            }


            // Subject Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Subject")
                    .font(.headline)
                TextField("eg: Mathematics", text: $subject)
                    .padding()
                    .background(Color(UIColor.systemGray5).opacity(0.5))
                    .cornerRadius(12)
            }

            // Due Date Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Due Date")
                    .font(.headline)
                TextField("yyyy-mm-dd", text: $dueDate)
                    .padding()
                    .background(Color(UIColor.systemGray5).opacity(0.5))
                    .cornerRadius(12)
                    .keyboardType(.numbersAndPunctuation)
            }

            // Inline error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }

            Spacer()

            // Actions
            VStack(spacing: 15) {
                Button {
                    saveCard()
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        }
                        Text(isSaving ? "Saving…" : "Add Card")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canSave ? Color.blue : Color.blue.opacity(0.4))
                    .cornerRadius(30)
                }
                .disabled(!canSave || isSaving)

                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.black)
            }
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Helpers
    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveCard() {
        isSaving = true
        errorMessage = nil

        viewModel.addCard(
            question: question.trimmingCharacters(in: .whitespaces),
            answer: "",   // answer is provided by the user when they tap Answer on the card
            subject: subject.trimmingCharacters(in: .whitespaces),
            dueDate: dueDate.trimmingCharacters(in: .whitespaces)
        ) { error in
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
}
