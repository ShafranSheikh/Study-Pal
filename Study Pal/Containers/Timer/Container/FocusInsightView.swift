import SwiftUI

struct FocusInsightsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = "Overview"
    
    var body: some View {
        VStack(spacing: 15) {
            // Header with Back Button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Focus insights")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Tab Component
            InsightTabView(selectedTab: $selectedTab)
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                if selectedTab == "Overview" {
                    FocusOverview()
                } else {
                    FocusPatternsView()
                }
                Spacer(minLength: 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
}
