import SwiftUI

struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title).bold()
                .foregroundColor(color)
            Text(label)
                .font(.caption).bold()
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GameBaseLayout<Content: View>: View {
    let title: String
    let stats: AnyView
    let color: Color
    let content: Content

    init(title: String, color: Color, stats: AnyView, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.stats = stats
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 25) {
            // Stats Bar
            HStack {
                stats
            }
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)

            // Game Area
            ZStack {
                color.opacity(0.1)
                    .cornerRadius(25)
                content
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 30)
        .background(Color.gray.opacity(0.05))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GameResultOverlay: View {
    let title: String
    let color: Color
    let scoreRows: [(label: String, value: String)]
    let xpAwarded: Int
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 24) {
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 44))
                        .foregroundColor(color)
                }

                Text("Game Over!")
                    .font(.title).bold()

                // Score rows
                VStack(spacing: 12) {
                    ForEach(scoreRows, id: \.label) { row in
                        HStack {
                            Text(row.label)
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(row.value)
                                .font(.body).bold()
                        }
                    }
                    Divider()
                    HStack {
                        Label("XP Awarded", systemImage: "star.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("+\(xpAwarded) XP")
                            .font(.body).bold()
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)

                // Actions
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(color)
                        .cornerRadius(14)
                    }

                    Button(action: onExit) {
                        Text("Back to Games")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 24)
        }
    }
}
