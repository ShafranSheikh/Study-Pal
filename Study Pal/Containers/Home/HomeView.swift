import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home Area")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
