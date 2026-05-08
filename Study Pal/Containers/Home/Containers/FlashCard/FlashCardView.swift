import SwiftUI

struct FlashCardsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FlashCardViewModel()

    @State private var showAddCard = false
    @State private var selectedCard: FlashCardItem? = nil
    @State private var showAnswerSheet = false
    @State private var selectedTab = "All subjects"

    var subjects: [String] {
        let base = ["All subjects"]
        let unique = Array(Set(viewModel.cards.map { $0.subject })).sorted()
        return base + unique
    }

    var filteredCards: [FlashCardItem] {
        if selectedTab == "All subjects" { return viewModel.cards }
        return viewModel.cards.filter { $0.subject == selectedTab }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Loading cards…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {

                            // Header
                            headerRow

                            // Stats
                            statsRow

                            // Subject Filter Tabs
                            subjectTabs

                            // Card List
                            cardList
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationDestination(isPresented: $showAddCard) {
                AddFlashCardView(viewModel: viewModel)
            }
            // Answer Sheet
            .sheet(isPresented: $showAnswerSheet) {
                if let card = selectedCard {
                    AnswerSheet(card: card, viewModel: viewModel)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var headerRow: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.trailing, 8)

            Text("Flash Cards")
                .font(.system(size: 32, weight: .bold))

            Spacer()

            Button {
                showAddCard = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var statsRow: some View {
        HStack(spacing: 15) {
            StatCardView(
                title: "\(viewModel.totalCards)",
                subtitle: "Total cards",
                color: .purple
            )
            StatCardView(
                title: "\(viewModel.dueTodayCount)",
                subtitle: "Due Today",
                color: .red
            )
            StatCardView(
                title: "\(viewModel.completionPercentage)%",
                subtitle: "Completed",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private var subjectTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(subjects, id: \.self) { subject in
                    Text(subject)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(
                            selectedTab == subject
                                ? Color.white
                                : Color.white.opacity(0.6)
                        )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    selectedTab == subject ? Color.blue : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture { selectedTab = subject }
                }
            }
            .padding(.horizontal)
        }
    }

    private var cardList: some View {
        VStack(spacing: 16) {
            if filteredCards.isEmpty {
                emptyState
            } else {
                ForEach(filteredCards) { card in
                    FlashCardRow(
                        card: card,
                        onAnswerTapped: {
                            selectedCard = card
                            showAnswerSheet = true
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteCard(card)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No flash cards yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to create your first card")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

private struct FlashCardRow: View {
    let card: FlashCardItem
    let onAnswerTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tags row
            HStack {
                Text(card.subject)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(6)

                if !card.dueDate.isEmpty {
                    Text("Due \(card.dueDate)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(6)
                }

                Spacer()

                
                if card.isAnswered {
                    Label("Answered", systemImage: "checkmark.circle.fill")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                }
            }

            // Question
            Text(card.question)
                .font(.body.bold())

            
            Button(action: onAnswerTapped) {
                Text(card.isAnswered ? "View Answer" : "Answer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(card.isAnswered ? Color.green : Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


private struct AnswerSheet: View {
    let card: FlashCardItem
    let viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var userAnswer: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Drag handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 6)

            Text("Flash Card")
                .font(.title3.bold())

            // Question block
            VStack(alignment: .leading, spacing: 8) {
                Label("Question", systemImage: "questionmark.circle.fill")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Text(card.question)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)

            if card.isAnswered {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Your Answer", systemImage: "lightbulb.fill")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    if card.answer.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("No answer was recorded.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Text(card.answer)
                            .font(.body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.orange.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                Button { dismiss() } label: {
                    Text("Done")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Your Answer", systemImage: "pencil")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    TextEditor(text: $userAnswer)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Spacer()

                Button {
                    submitAnswer()
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView().tint(.white).padding(.trailing, 4)
                        }
                        Text(isSaving ? "Saving…" : "Submit Answer")
                    }
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSubmit ? Color.blue : Color.blue.opacity(0.4))
                    .cornerRadius(12)
                }
                .disabled(!canSubmit || isSaving)
            }
        }
        .padding(28)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private var canSubmit: Bool {
        !userAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitAnswer() {
        isSaving = true
        errorMessage = nil
        viewModel.saveAnswer(for: card, answer: userAnswer) { error in
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


struct StatCardView: View {
    var title: String
    var subtitle: String
    var color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(18)
    }
}
