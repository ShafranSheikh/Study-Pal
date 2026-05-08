import SwiftUI
struct SpeedClickView: View {

    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    enum GameState { case idle, playing, finished }

    @State private var gameState: GameState = .idle
    @State private var clicks: Int = 0
    @State private var score: Int = 0
    @State private var timeLeft: Int = 30
    @State private var targetPosition: CGPoint = .zero
    @State private var timer: Timer? = nil
    @State private var savedResult: GameResult? = nil
    @State private var xpAwarded: Int = 0
    @State private var showMiss: Bool = false

    private let gameDuration = 30

    var body: some View {
        ZStack {
            GameBaseLayout(
                title: "Speed Click",
                color: .orange,
                stats: AnyView(
                    Group {
                        StatBox(value: "\(score)", label: "Score", color: .purple)
                        StatBox(value: "\(clicks)", label: "Clicks", color: .green)
                        StatBox(value: "\(timeLeft)s", label: "Time left", color: timeLeft <= 5 ? .red : .orange)
                    }
                )
            ) {
                gameArea
            }

            // Result overlay
            if gameState == .finished, let result = savedResult {
                GameResultOverlay(
                    title: "Speed Click",
                    color: .orange,
                    scoreRows: [
                        ("Score", "\(result.score)"),
                        ("Targets Hit", "\(result.clicks ?? 0)"),
                        ("Time", "\(gameDuration)s")
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
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Speed Click")
                .font(.title2).bold()
            Text("Tap the orange target as fast as you can!\nYou have \(gameDuration) seconds.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Start Game") { startGame() }
                .padding(.horizontal, 30).padding(.vertical, 12)
                .background(Color.orange).foregroundColor(.white).cornerRadius(25)
                .font(.headline)
        }
        .padding(.vertical, 30)
    }

    private var playingScreen: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { handleMiss() }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow, .orange],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .orange.opacity(0.5), radius: 8)
                    .position(targetPosition)
                    .onTapGesture { handleHit(in: geo) }
                    .animation(.spring(response: 0.2), value: targetPosition)

                if showMiss {
                    Text("Miss!")
                        .font(.caption).bold()
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            .onAppear { placeTarget(in: geo) }
        }
        .frame(height: 320)
    }


    private func startGame() {
        clicks = 0
        score = 0
        timeLeft = gameDuration
        savedResult = nil
        gameState = .playing
        startTimer()
    }

    private func resetGame() {
        stopTimer()
        gameState = .idle
    }

    private func handleHit(in geo: GeometryProxy) {
        clicks += 1
        score += 10
        placeTarget(in: geo)
    }

    private func handleMiss() {
        score = max(0, score - 2)
        showMiss = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showMiss = false }
    }

    private func placeTarget(in geo: GeometryProxy) {
        let padding: CGFloat = 40
        let x = CGFloat.random(in: padding...(geo.size.width - padding))
        let y = CGFloat.random(in: padding...(geo.size.height - padding))
        targetPosition = CGPoint(x: x, y: y)
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
            gameType: GameViewModel.speedClick,
            score: score,
            clicks: clicks
        )
        savedResult = result
        gameVM.saveResult(result)
        
        // Notifications
        if score >= 150 {
            NotificationManager.shared.sendGameWinNotification(gameName: "Speed Click", score: score)
        } else if score < 50 {
            NotificationManager.shared.sendGameLossNotification(gameName: "Speed Click", score: score)
        }
        
        withAnimation { gameState = .finished }
    }
}
