import SwiftUI

struct AddFlashCardView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var question = ""
    @State private var subject = ""
    @State private var dueDate = ""

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
            
            Text("create Flash Card")
                .font(.system(size: 34, weight: .bold))
            
            // Question Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Question")
                    .font(.headline)
                TextEditor(text: $question)
                    .frame(height: 120)
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
            
            // Date Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Due date")
                    .font(.headline)
                TextField("yyyy-mm-dd", text: $dueDate)
                    .padding()
                    .background(Color(UIColor.systemGray5).opacity(0.5))
                    .cornerRadius(12)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 15) {
                Button {
                    // Logic to save the card would go here
                    dismiss()
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                
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
}
