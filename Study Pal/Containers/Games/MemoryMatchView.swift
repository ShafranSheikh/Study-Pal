import SwiftUI

private struct MemoryCard: Identifiable {
    let id: Int
    let emoji: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemoryMatchView: View {

    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    private let emojis = ["🧠", "📚", "🎓", "✏️", "🔬", "💡", "📝", "🖊️"]

    @State private var cards: [MemoryCard] = []
    @State private var firstFlipped: Int? = nil
    @State private var isLocked: Bool = false
    @State private var moves: Int = 0
    @State private var matchesFound: Int = 0
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer? = nil
    @State private var gameFinished: Bool = false
    @State private var savedResult: GameResult? = nil
    @State private var xpAwarded: Int = 0

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

    private func resetGame() {
        stopTimer()
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
        cards[card.id].isFaceUp = true

        if let first = firstFlipped {
            moves += 1
            isLocked = true

            if cards[first].emoji == card.emoji {
                cards[first].isMatched = true
                cards[card.id].isMatched = true
                matchesFound += 1
                firstFlipped = nil
                isLocked = false

                if matchesFound == 8 {
                    finishGame()
                }
            } else {
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

        // Notifications
        NotificationManager.shared.sendGameWinNotification(gameName: "Memory Match", score: score)

        withAnimation { gameFinished = true }
    }

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
