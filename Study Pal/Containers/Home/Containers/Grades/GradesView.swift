import SwiftUI

// MARK: - GradesView
/// Displays subject-level grade summaries fetched from Firestore via GradeViewModel.
/// Each subject card shows the average score, target, and most recent event.
/// Swipe left on a subject row to delete all entries for that subject.
struct GradesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GradeViewModel()
    @State private var showAddGrade = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading grades…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // ── Header ──────────────────────────────────────────
                        headerRow

                        // ── Overall Performance Banner ───────────────────────
                        overallBanner

                        // ── Subject Cards ────────────────────────────────────
                        if viewModel.subjectSummaries.isEmpty {
                            emptyState
                        } else {
                            subjectList
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAddGrade) {
            AddGradeView(viewModel: viewModel)
        }
    }

    // MARK: - Header
    private var headerRow: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.title2.bold())
                    .foregroundColor(.black)
            }
            Text("Grades")
                .font(.system(size: 32, weight: .bold))
            Spacer()
            Button { showAddGrade = true } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Overall Banner
    private var overallBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "medal.fill")
                Text("Overall performance")
            }
            .font(.subheadline.bold())

            Text("\(Int(viewModel.overallAverage.rounded()))%")
                .font(.system(size: 48, weight: .bold))

            Text("Average across all subjects")
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .padding(.horizontal)
    }

    // MARK: - Subject List
    private var subjectList: some View {
        VStack(spacing: 15) {
            ForEach(viewModel.subjectSummaries) { summary in
                SubjectCard(summary: summary)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteSubject(summary)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No grades yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to add your first grade entry")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    // MARK: - Delete all entries for a subject
    private func deleteSubject(_ summary: SubjectSummary) {
        summary.entries.forEach { viewModel.deleteGrade($0) }
    }
}

// MARK: - SubjectCard
/// Displays averaged score, target, progress bar and most recent event for one subject.
private struct SubjectCard: View {
    let summary: SubjectSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(summary.name)
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(Int(summary.averagePercentage.rounded()))%")
                        .font(.headline)
                        .foregroundColor(summary.color)
                    Text("Target: \(Int(summary.target.rounded()))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            ProgressView(value: min(summary.ratio, 1.0))
                .tint(summary.color)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text("Recent: \(summary.recentEvent)")
                Spacer()
                Text(summary.recentDate)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
