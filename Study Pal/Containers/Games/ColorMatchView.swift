import SwiftUI

struct ColorMatchView: View {

    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    enum GameState { case idle, playing, finished }

    @State private var gameState: GameState = .idle
    @State private var score: Int = 0
    @State private var round: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var timeLeft: Int = 30
    @State private var timer: Timer? = nil
    @State private var savedResult: GameResult? = nil
    @State private var xpAwarded: Int = 0

    @State private var wordText: String = ""
    @State private var inkColor: Color = .black
    @State private var correctAnswer: Bool = true   
    @State private var feedbackColor: Color? = nil

    private let gameDuration = 30

    private let colorPairs: [(name: String, color: Color)] = [
        ("Red", .red),
        ("Blue", .blue),
        ("Green", .green),
        ("Yellow", .yellow),
        ("Purple", .purple),
        ("Orange", .orange)
    ]

    var body: some View {
        ZStack {
            GameBaseLayout(
                title: "Color Match",
                color: .pink,
                stats: AnyView(
                    Group {
                        StatBox(value: "\(score)", label: "Score", color: .purple)
                        StatBox(value: "\(round)", label: "Round", color: .green)
                        StatBox(value: "\(timeLeft)s", label: "Time left", color: timeLeft <= 5 ? .red : .pink)
                    }
                )
            ) {
                gameArea
            }

            // Result overlay
            if gameState == .finished, let result = savedResult {
                GameResultOverlay(
                    title: "Color Match",
                    color: .pink,
                    scoreRows: [
                        ("Score", "\(result.score)"),
                        ("Correct Answers", "\(result.correctAnswers ?? 0)"),
                        ("Rounds Played", "\(round)")
                    ],
                    xpAwarded: xpAwarded,
                    onPlayAgain: { resetGame() },
                    onExit: { dismiss() }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onDisappear { stopTimer() }
        .animation(.easeInOut(duration: 0.3), value: gameState == .finished)
    }

    @ViewBuilder
    private var gameArea: some View {
        switch gameState {
        case .idle:
            idleScreen
        case .playing:
            playingScreen
        case .finished:
            Color.clear.frame(height: 300)
        }
    }

    private var idleScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60)).foregroundColor(.pink)
            Text("Color Match").font(.title2).bold()
            Text("Does the word's **color** match\nwhat it says? Quick — \(gameDuration)s!")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(spacing: 6) {
                Text("Example:").font(.caption).foregroundColor(.secondary)
                Text("Blue")
                    .font(.title2).bold()
                    .foregroundColor(.red)
                Text("Word says \"Blue\" but color is Red → No Match")
                    .font(.caption2).multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)

            Button("Start Game") { startGame() }
                .padding(.horizontal, 30).padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.pink, .purple],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white).cornerRadius(25)
                .font(.headline)
        }
        .padding(.vertical, 20)
    }

    private var playingScreen: some View {
        VStack(spacing: 24) {
            Text("Does the color match?")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(wordText)
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(inkColor)
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(feedbackColor?.opacity(0.12) ?? Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(feedbackColor ?? Color.clear, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: feedbackColor)

            HStack(spacing: 16) {
                AnswerButton2(label: "✓ Match", color: .green) { submitAnswer(true) }
                AnswerButton2(label: "✗ No Match", color: .red) { submitAnswer(false) }
            }
        }
        .padding()
    }


    private func startGame() {
        score = 0
        round = 0
        correctAnswers = 0
        timeLeft = gameDuration
        savedResult = nil
        generateRound()
        gameState = .playing
        startTimer()
    }

    private func resetGame() {
        stopTimer()
        gameState = .idle
    }

    private func generateRound() {
        let wordPair = colorPairs.randomElement()!
        wordText = wordPair.name

        if Bool.random() {
            inkColor = wordPair.color
            correctAnswer = true
        } else {
            let others = colorPairs.filter { $0.name != wordPair.name }
            inkColor = others.randomElement()!.color
            correctAnswer = false
        }
    }

    private func submitAnswer(_ playerAnswer: Bool) {
        round += 1
        if playerAnswer == correctAnswer {
            correctAnswers += 1
            score += 10
            flashFeedback(.green)
        } else {
            score = max(0, score - 5)
            flashFeedback(.red)
        }
        generateRound()
    }

    private func flashFeedback(_ color: Color) {
        feedbackColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            feedbackColor = nil
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                finishGame()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishGame() {
        stopTimer()
        xpAwarded = max(25, (score / 10) * 5)

        let result = GameResult(
            gameType: GameViewModel.colorMatch,
            score: score,
            correctAnswers: correctAnswers
        )
        savedResult = result
        gameVM.saveResult(result)
        withAnimation { gameState = .finished }
    }
}

private struct AnswerButton2: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(14)
        }
    }
}
