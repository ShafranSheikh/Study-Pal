import SwiftUI

struct InsightTabView: View {
    @Binding var selectedTab: String
    let tabs = ["Overview", "Patterns"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab)
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? Color.white : Color.clear)
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .cornerRadius(25)
                        .padding(4)
                }
            }
        }
        .background(Color(uiColor: .systemGray5).opacity(0.6))
        .cornerRadius(30)
    }
}
