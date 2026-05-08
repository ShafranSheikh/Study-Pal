import SwiftUI

struct MathRushView: View {

    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    enum GameState { case idle, playing, finished }

    @State private var gameState: GameState = .idle
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var timeLeft: Int = 60
    @State private var timer: Timer? = nil
    @State private var savedResult: GameResult? = nil
    @State private var xpAwarded: Int = 0

    // Current question
    @State private var questionText: String = ""
    @State private var correctAnswer: Bool = true
    @State private var feedbackColor: Color? = nil

    private let gameDuration = 60

    var body: some View {
        ZStack {
            GameBaseLayout(
                title: "Math Rush",
                color: .green,
                stats: AnyView(
                    Group {
                        StatBox(value: "\(score)", label: "Score", color: .purple)
                        StatBox(value: "\(streak)🔥", label: "Streak", color: .green)
                        StatBox(value: "\(timeLeft)s", label: "Time left", color: timeLeft <= 10 ? .red : .green)
                    }
                )
            ) {
                gameArea
            }

            // Result overlay
            if gameState == .finished, let result = savedResult {
                GameResultOverlay(
                    title: "Math Rush",
                    color: .green,
                    scoreRows: [
                        ("Score", "\(result.score)"),
                        ("Correct Answers", "\(result.correctAnswers ?? 0)"),
                        ("Best Streak", "\(result.streak ?? 0)🔥")
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
            Image(systemName: "plus.forwardslash.minus")
                .font(.system(size: 60))
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(15)
            Text("Solve as many math problems\nas you can in \(gameDuration) seconds!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Start Game") { startGame() }
                .padding(.horizontal, 30).padding(.vertical, 12)
                .background(Color.green).foregroundColor(.white).cornerRadius(25)
                .font(.headline)
        }
        .padding(.vertical, 30)
    }

    private var playingScreen: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Is this correct?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(questionText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(feedbackColor?.opacity(0.15) ?? Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(feedbackColor ?? Color.clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: feedbackColor)

            HStack(spacing: 16) {
                AnswerButton(label: "✓ True", color: .green) { submitAnswer(true) }
                AnswerButton(label: "✗ False", color: .red) { submitAnswer(false) }
            }
        }
        .padding()
    }

    private func startGame() {
        score = 0
        streak = 0
        correctAnswers = 0
        timeLeft = gameDuration
        savedResult = nil
        generateQuestion()
        gameState = .playing
        startTimer()
    }

    private func resetGame() {
        stopTimer()
        gameState = .idle
    }

    private func generateQuestion() {
        let a = Int.random(in: 1...20)
        let b = Int.random(in: 1...20)
        let ops: [(String, Int)] = [("+", a + b), ("-", a - b), ("×", a * b)]
        let (opSymbol, realAnswer) = ops.randomElement()!

        let showWrong = Bool.random()
        let displayedAnswer: Int
        if showWrong {
            let offset = Int.random(in: 1...5) * (Bool.random() ? 1 : -1)
            displayedAnswer = realAnswer + offset
            correctAnswer = false
        } else {
            displayedAnswer = realAnswer
            correctAnswer = true
        }

        questionText = "\(a) \(opSymbol) \(b) = \(displayedAnswer)"
    }

    private func submitAnswer(_ playerAnswer: Bool) {
        if playerAnswer == correctAnswer {
            streak += 1
            correctAnswers += 1
            let bonus = streak >= 3 ? 20 : 10 
            score += bonus
            flashFeedback(.green)
        } else {
            streak = 0
            score = max(0, score - 5)
            flashFeedback(.red)
        }
        generateQuestion()
    }

    private func flashFeedback(_ color: Color) {
        feedbackColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
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
            gameType: GameViewModel.mathRush,
            score: score,
            correctAnswers: correctAnswers,
            streak: streak
        )
        savedResult = result
        gameVM.saveResult(result)
        
        // Notifications
        if score >= 100 {
            NotificationManager.shared.sendGameWinNotification(gameName: "Math Rush", score: score)
        } else if score < 20 {
            NotificationManager.shared.sendGameLossNotification(gameName: "Math Rush", score: score)
        }
        
        withAnimation { gameState = .finished }
    }
}


private struct AnswerButton: View {
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
