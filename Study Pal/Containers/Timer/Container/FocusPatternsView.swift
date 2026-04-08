import SwiftUI

struct FocusPatternsView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Peak Time Card
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 100)
                .overlay(
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Your Peak Time")
                            }.font(.caption.bold())
                            Text("Morning").font(.title2.bold())
                            Text("Highest focus score 10/10").font(.caption)
                        }
                        Spacer()
                    }.foregroundColor(.white).padding()
                )
            
            chartBox(title: "Weekly study Pattern", label: "bar chart placeholder")
            chartBox(title: "Focus by time of day", label: "bar chart placeholder")
            chartBox(title: "Time by subject", label: "pi chart placeholder")
        }
        .padding(.horizontal)
    }
    
    private func chartBox(title: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemGray5).opacity(0.5))
                .frame(height: 120)
                .overlay(Text(label).foregroundColor(.gray).font(.footnote))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
