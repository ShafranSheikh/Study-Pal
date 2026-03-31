import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Games Area")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Games")
        }
    }
}

#Preview {
    GamesView()
}
