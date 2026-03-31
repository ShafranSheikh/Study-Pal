import SwiftUI

struct TimerView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Timer Area")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Timer")
        }
    }
}

#Preview {
    TimerView()
}
