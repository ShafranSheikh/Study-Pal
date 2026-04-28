import SwiftUI

// MARK: - Memory Match Card Model
private struct MemoryCard: Identifiable {
    let id: Int
    let emoji: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

// MARK: - MemoryMatchView
/// Memory Match game — starts immediately on appear.
/// A 4×4 grid of 8 emoji pairs. Player flips cards to find matches.
/// Score = matches found; Time counts up; Moves tracked.
/// Result is saved to Firestore on completion.
struct MemoryMatchView: View {

    // MARK: - State
    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    private let emojis = ["🧠", "📚", "🎓", "✏️", "🔬", "💡", "📝", "🖊️"]

    @State private var cards: [MemoryCard] = []
    @State private var firstFlipped: Int? = nil   // index of first flipped card
    @State private var isLocked: Bool = false      // prevent tapping during mismatch delay
    @State private var moves: Int = 0
    @State private var matchesFound: Int = 0
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer? = nil
    @State private var gameFinished: Bool = false
    @State private var savedResult: GameResult? = nil
    @State private var xpAwarded: Int = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            GameBaseLayout(
                title: "Memory Match",
                color: .blue,
                stats: AnyView(
                    Group {
                        StatBox(value: "\(moves)", label: "Moves", color: .purple)
                        StatBox(value: "\(matchesFound)/8", label: "Matches", color: .green)
                        StatBox(value: timeString(timeElapsed), label: "Time", color: .blue)
                    }
                )
            ) {
                cardGrid
            }

            // Result overlay when game is won
            if gameFinished, let result = savedResult {
                GameResultOverlay(
                    title: "Memory Match",
                    color: .blue,
                    scoreRows: [
                        ("Matches Found", "\(result.moves.map { _ in matchesFound } ?? matchesFound)/8"),
                        ("Moves Made", "\(result.moves ?? moves)"),
                        ("Time Taken", timeString(result.timeElapsed ?? timeElapsed))
                    ],
                    xpAwarded: xpAwarded,
                    onPlayAgain: { resetGame() },
                    onExit: { dismiss() }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear { resetGame() }
        .onDisappear { stopTimer() }
        .animation(.easeInOut(duration: 0.3), value: gameFinished)
    }

    // MARK: - Card Grid
    private var cardGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 4),
            spacing: 10
        ) {
            ForEach(cards) { card in
                CardView(card: card)
                    .onTapGesture { handleTap(card: card) }
            }
        }
        .padding()
    }

    // MARK: - Game Logic

    private func resetGame() {
        stopTimer()
        // Build shuffled deck of 8 pairs
        let pairs = emojis.flatMap { [$0, $0] }.shuffled()
        cards = pairs.enumerated().map { MemoryCard(id: $0.offset, emoji: $0.element) }
        firstFlipped = nil
        isLocked = false
        moves = 0
        matchesFound = 0
        timeElapsed = 0
        gameFinished = false
        savedResult = nil
        startTimer()
    }

    private func handleTap(card: MemoryCard) {
        guard !isLocked,
              !card.isFaceUp,
              !card.isMatched else { return }

        // Flip card face up
        cards[card.id].isFaceUp = true

        if let first = firstFlipped {
            // Second card flipped – check for match
            moves += 1
            isLocked = true

            if cards[first].emoji == card.emoji {
                // Match!
                cards[first].isMatched = true
                cards[card.id].isMatched = true
                matchesFound += 1
                firstFlipped = nil
                isLocked = false

                if matchesFound == 8 {
                    finishGame()
                }
            } else {
                // No match – flip both back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cards[first].isFaceUp = false
                    cards[card.id].isFaceUp = false
                    firstFlipped = nil
                    isLocked = false
                }
            }
        } else {
            firstFlipped = card.id
        }
    }

    private func finishGame() {
        stopTimer()
        // Score formula: penalise for moves, reward for fast time
        let baseScore = 800
        let movePenalty = max(0, (moves - 8) * 10)
        let timePenalty = max(0, (timeElapsed - 30) * 2)
        let score = max(50, baseScore - movePenalty - timePenalty)

        xpAwarded = max(25, (score / 10) * 5)

        let result = GameResult(
            gameType: GameViewModel.memoryMatch,
            score: score,
            moves: moves,
            timeElapsed: timeElapsed
        )
        savedResult = result
        gameVM.saveResult(result)

        withAnimation { gameFinished = true }
    }

    // MARK: - Timer Helpers
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Card View
private struct CardView: View {
    let card: MemoryCard

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isMatched
                          ? LinearGradient(colors: [.green.opacity(0.7), .mint], startPoint: .top, endPoint: .bottom)
                          : LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.isMatched ? Color.green : Color.purple.opacity(0.3), lineWidth: 2)
                    )
                Text(card.emoji)
                    .font(.title2)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
                Text("?")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.title3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: card.isFaceUp)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: card.isMatched)
    }
}
