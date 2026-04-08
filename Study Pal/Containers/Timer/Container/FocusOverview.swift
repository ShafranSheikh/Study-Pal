import SwiftUI

struct FocusOverview: View {
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
                        Text("2h 30m").font(.system(size: 28, weight: .bold))
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
                        Text("7/10").font(.system(size: 28, weight: .bold))
                        Text("Average focus score").font(.subheadline)
                    }
                    .foregroundColor(.white).padding(), alignment: .leading
                )
            
            Text("Recent Focus Sessions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            VStack(spacing: 0) {
                sessionRow(title: "Mathematics", date: "03/23/2026", time: "25 min", score: "10/10")
                Divider().padding(.horizontal)
                sessionRow(title: "History", date: "03/22/2026", time: "18 min", score: "7/10")
                Divider().padding(.horizontal)
                sessionRow(title: "Chemistry", date: "03/22/2026", time: "18 min", score: "7/10")
            }
            .background(Color.white)
            .cornerRadius(20)
        }
        .padding(.horizontal)
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
