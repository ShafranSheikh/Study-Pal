import SwiftUI

struct FocusOverview: View {
    @ObservedObject var viewModel: FocusInsightsViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Focus Time Card
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.blue.opacity(0.7), .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 120)
                .overlay(
                    VStack(alignment: .leading) {
                        Image(systemName: "clock").font(.title2)
                        Spacer()
                        Text(viewModel.totalFocusTime).font(.system(size: 28, weight: .bold))
                        Text("Total Focus time").font(.subheadline)
                    }
                    .foregroundColor(.white).padding(), alignment: .leading
                )
            
            // Score Card
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0, green: 0.65, blue: 0.35))
                .frame(height: 120)
                .overlay(
                    VStack(alignment: .leading) {
                        Image(systemName: "scope").font(.title2)
                        Spacer()
                        Text(viewModel.averageFocusScore).font(.system(size: 28, weight: .bold))
                        Text("Average focus score").font(.subheadline)
                    }
                    .foregroundColor(.white).padding(), alignment: .leading
                )
            
            Text("Recent Focus Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            VStack(spacing: 0) {
                if viewModel.recentSessions.isEmpty {
                    Text("No sessions recorded yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.recentSessions) { session in
                        sessionRow(
                            title: session.taskTitle ?? "General Focus",
                            date: session.date.formatted(date: .numeric, time: .omitted),
                            time: "\(session.duration / 60) min",
                            score: calculateScore(duration: session.duration)
                        )
                        if session.id != viewModel.recentSessions.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(20)
        }
        .padding(.horizontal)
    }
    
    private func calculateScore(duration: Int) -> String {
        let score = min(10, Int((Double(duration) / 1500.0) * 10))
        return "\(score)/10"
    }
    
    private func sessionRow(title: String, date: String, time: String, score: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(date).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(time).font(.subheadline.bold())
                Text(score).font(.caption).foregroundColor(.gray)
            }
        }.padding()
    }
}
