import SwiftUI

// MARK: - Game Model
struct Game: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let reward: String
    let icon: String
    let color: Color
    let gameTypeKey: String  // matches GameViewModel constants
}

struct GamesView: View {

    @StateObject private var gameVM = GameViewModel()

    // Data for the games
    let games = [
        Game(name: "Memory Match", subtitle: "Match Pairs to win coins", reward: "5 - 10 coins",
             icon: "square.grid.2x2.fill", color: .blue, gameTypeKey: GameViewModel.memoryMatch),
        Game(name: "Speed Click", subtitle: "Test your reflexes", reward: "15 - 20 coins",
             icon: "cursorarrow.click.2", color: .orange, gameTypeKey: GameViewModel.speedClick),
        Game(name: "Math Rush", subtitle: "Quick Math Challenges", reward: "25 - 30 coins",
             icon: "plus.forwardslash.minus", color: .green, gameTypeKey: GameViewModel.mathRush),
        Game(name: "Color Match", subtitle: "Match the colors fast", reward: "15 - 25 coins",
             icon: "paintpalette.fill", color: .pink, gameTypeKey: GameViewModel.colorMatch)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header Section
                    GamesHeaderView()

                    // Why Brain Breaks Section
                    InfoBanner()
                        .padding(.horizontal)

                    // Choose a Game Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Choose a Game")
                            .font(.title2)
                            .bold()

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(games) { game in
                                NavigationLink(destination: destinationView(for: game.name)) {
                                    GameCard(game: game)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)

                    // High Scores Section — fetched from Firestore
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your High Scores")
                            .font(.title2)
                            .bold()

                        VStack(spacing: 12) {
                            ForEach(games) { game in
                                ScoreRow(
                                    game: game,
                                    bestScore: gameVM.highScores[game.gameTypeKey] ?? 0
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
                .background(Color.gray.opacity(0.09))
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear { gameVM.fetchHighScores() }
        }
    }

    // MARK: - Routing Helper
    @ViewBuilder
    func destinationView(for gameName: String) -> some View {
        switch gameName {
        case "Memory Match": MemoryMatchView()
        case "Speed Click":  SpeedClickView()
        case "Math Rush":    MathRushView()
        case "Color Match":  ColorMatchView()
        default:             Text("Game under development")
        }
    }
}

// MARK: - Subviews

struct GamesHeaderView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [.indigo, .purple]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 180)

            HStack {
                VStack(alignment: .leading) {
                    Text("Brain Break Games")
                        .font(.title).bold()
                    Text("Take a break and earn rewards")
                        .font(.subheadline)
                }
                .foregroundColor(.white)

                Spacer()

                VStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("0").font(.title).bold()
                    Text("Your Coins").font(.caption2)
                }
                .foregroundColor(.white)
            }
            .padding(25)
        }
    }
}

struct InfoBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why take brain breaks?")
                .font(.headline)
            Text("Brain break games help students refresh their minds, reduce stress, and improve focus.")
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(gradient: Gradient(colors: [.orange, .pink]),
                           startPoint: .leading, endPoint: .trailing)
        )
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

struct GameCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: game.icon)
                .font(.title)

            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.headline)
                Text(game.subtitle)
                    .font(.caption2)
                    .opacity(0.9)
            }

            Text(game.reward)
                .font(.caption.bold())
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(game.color)
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}

struct ScoreRow: View {
    let game: Game
    let bestScore: Int

    var body: some View {
        HStack {
            Image(systemName: game.icon)
                .foregroundColor(game.color)
                .frame(width: 40, height: 40)
                .background(game.color.opacity(0.1))
                .cornerRadius(10)

            Text(game.name)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(bestScore)").bold()
                Text("Best").font(.caption2).foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    GamesView()
}
