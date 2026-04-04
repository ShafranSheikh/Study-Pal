import SwiftUI

struct AddGradeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""; @State private var category = "Assignment"; @State private var name = ""
    @State private var score = ""; @State private var maxScore = ""; @State private var target = ""; @State private var date = ""
    let categories = ["Assignment", "Exam", "Quiz", "Project"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left").font(.title2.bold()).foregroundColor(.black)
            }
            Text("Add grade").font(.system(size: 34, weight: .bold))
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Subject").bold()
                    TextField("eg: Mathematics", text: $subject).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12)
                    
                    Text("Category").bold()
                    Picker("Category", selection: $category) { ForEach(categories, id: \.self) { Text($0) } }
                    .pickerStyle(.menu).frame(maxWidth: .infinity).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12)
                    
                    Text("Name").bold()
                    TextField("eg: Midterm", text: $name).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12)
                    
                    HStack(spacing: 15) {
                        VStack(alignment: .leading) { Text("Score").bold(); TextField("e.g: 80", text: $score).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12) }
                        VStack(alignment: .leading) { Text("Max Score").bold(); TextField("e.g: 100", text: $maxScore).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12) }
                    }
                    Text("Target").bold(); TextField("e.g: 85", text: $target).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12)
                    Text("Date").bold(); TextField("dd-mm-yyyy", text: $date).padding().background(Color(UIColor.systemGray5).opacity(0.5)).cornerRadius(12)
                }
            }
            VStack(spacing: 15) {
                Button { dismiss() } label: {
                    Text("Add Grade").bold().foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(30)
                }
                Button("Cancel") { dismiss() }.foregroundColor(.black)
            }
        }.padding(25).navigationBarBackButtonHidden(true).background(Color(UIColor.systemBackground))
    }
}
