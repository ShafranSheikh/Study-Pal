import SwiftUI

struct FocusPatternsView: View {
    @ObservedObject var viewModel: FocusInsightsViewModel
    
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
                            Text(viewModel.peakTime).font(.title2.bold())
                            Text("Highest focus frequency").font(.caption)
                        }
                        Spacer()
                    }.foregroundColor(.white).padding()
                )
            
            weeklyPatternBox
            timeOfDayBox
            subjectDistributionBox
        }
        .padding(.horizontal)
    }
    
    private var weeklyPatternBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly study Pattern").font(.headline)
            HStack(alignment: .bottom, spacing: 8) {
                let days = ["M", "T", "W", "T", "F", "S", "S"]
                let maxVal = viewModel.weeklyPattern.max() ?? 1
                
                ForEach(0..<7) { index in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(height: maxVal > 0 ? CGFloat((viewModel.weeklyPattern[index] / maxVal) * 80) : 0)
                        Text(days[index]).font(.caption2).foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
    
    private var timeOfDayBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus by time of day").font(.headline)
            HStack(alignment: .bottom, spacing: 15) {
                let labels = ["Morn", "Aft", "Eve", "Night"]
                let maxVal = viewModel.timeOfDayPattern.max() ?? 1
                
                ForEach(0..<4) { index in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.indigo)
                            .frame(height: maxVal > 0 ? CGFloat((viewModel.timeOfDayPattern[index] / maxVal) * 80) : 0)
                        Text(labels[index]).font(.caption2).foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
    
    private var subjectDistributionBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time by subject").font(.headline)
            if viewModel.subjectDistribution.isEmpty {
                Text("No subject data available").foregroundColor(.gray).font(.footnote)
            } else {
                VStack(spacing: 8) {
                    let sortedSubjects = viewModel.subjectDistribution.sorted(by: { $0.value > $1.value })
                    let total = Double(sortedSubjects.reduce(0) { $0 + $1.value })
                    
                    ForEach(sortedSubjects.prefix(4), id: \.key) { subject, duration in
                        HStack {
                            Text(subject).font(.caption).frame(width: 80, alignment: .leading)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.orange)
                                    .frame(width: geo.size.width * CGFloat(Double(duration) / total))
                            }
                            .frame(height: 8)
                            Text("\(duration / 60)m").font(.caption2).foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
