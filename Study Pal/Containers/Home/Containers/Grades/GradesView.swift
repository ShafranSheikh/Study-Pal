import SwiftUI

struct SubjectGrade: Identifiable {
    let id = UUID(); let name: String; let score: Double; let target: Double; let recentEvent: String; let date: String; let color: Color
}

struct GradesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAddGrade = false
    
    let grades = [
        SubjectGrade(name: "Mathematics", score: 0.825, target: 0.90, recentEvent: "Midterm", date: "20-03-2026", color: .green),
        SubjectGrade(name: "Chemistry", score: 0.60, target: 0.80, recentEvent: "In class Test", date: "01-03-2026", color: .purple),
        SubjectGrade(name: "History", score: 0.705, target: 0.90, recentEvent: "Midterm", date: "20-02-2026", color: .blue),
        SubjectGrade(name: "Physics", score: 0.50, target: 0.70, recentEvent: "Quiz competition", date: "12-02-2026", color: .red)
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.left").font(.title2.bold()).foregroundColor(.black)
                        }
                        Text("Grades").font(.system(size: 32, weight: .bold))
                        Spacer()
                        Button { showAddGrade = true } label: {
                            Image(systemName: "plus").font(.title2.bold()).foregroundColor(.white).frame(width: 56, height: 56).background(Color.green).clipShape(Circle())
                        }
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Image(systemName: "medal.fill"); Text("Overall performance") }.font(.subheadline.bold())
                        Text("87%").font(.system(size: 48, weight: .bold))
                        Text("Average across all subjects").font(.subheadline)
                    }
                    .foregroundColor(.white).padding(25).frame(maxWidth: .infinity, alignment: .leading).background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)).cornerRadius(25).padding(.horizontal)

                    VStack(spacing: 15) {
                        ForEach(grades) { grade in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(grade.name).font(.headline)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(Int(grade.score * 100))%").font(.headline).foregroundColor(grade.color)
                                        Text("Target: \(Int(grade.target * 100))%").font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                                ProgressView(value: grade.score).tint(grade.color).scaleEffect(x: 1, y: 2, anchor: .center)
                                HStack { Text("Recent: \(grade.recentEvent)"); Spacer(); Text(grade.date) }.font(.caption2).foregroundColor(.secondary)
                            }.padding().background(Color.white).cornerRadius(20)
                        }
                    }.padding(.horizontal)
                }.padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAddGrade) { AddGradeView() }
    }
}
