import SwiftUI

struct TasksView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Tasks Area")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    TasksView()
}
