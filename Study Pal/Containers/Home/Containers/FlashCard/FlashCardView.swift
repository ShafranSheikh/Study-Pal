import SwiftUI

struct FlashCard: Identifiable {
    let id = UUID()
    var question: String
    var subject: String
    var dueDate: Date
}

struct FlashCardsView: View {
    @Environment(\.dismiss) var dismiss // Added to enable the back button
    @State private var showAddCard = false
    @State private var showAnswerPopup = false
    @State private var selectedTab = "All subjects"
    @State private var selectedQuestion: FlashCard?
    @State private var answerText = ""
    
    // Sample Data
    @State private var cards = [
        FlashCard(question: "What is pythagorean theorem?", subject: "Mathematics", dueDate: Date()),
        FlashCard(question: "What is Newton's second law?", subject: "Physics", dueDate: Date()),
        FlashCard(question: "What is the molecular formula of water?", subject: "Chemistry", dueDate: Date())
    ]
    
    // Logic to generate tabs dynamically
    var subjects: [String] {
        let base = ["All subjects"]
        let uniqueSubjects = Array(Set(cards.map { $0.subject })).sorted()
        return base + uniqueSubjects
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Custom Header with back button
                        HStack {
                            // Unified Back Button with custom arrow style
                            Button(action: {
                                dismiss() // Goes back to the previous screen
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold)) // Same style as add page
                                    .foregroundColor(.black) // Same color as add page
                            }
                            .padding(.trailing, 8) // Small space before the title
                            
                            Text("Flash Cards")
                                .font(.system(size: 32, weight: .bold))
                            
                            Spacer()
                            
                            // Keep the add button on the right
                            Button {
                                showAddCard = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Stats Summary Row
                        HStack(spacing: 15) {
                            StatCardView(title: "\(cards.count)", subtitle: "Total cards", color: .purple)
                            StatCardView(title: "2", subtitle: "Due Today", color: .red)
                            StatCardView(title: "100%", subtitle: "Completed", color: .green)
                        }
                        .padding(.horizontal)

                        // Dynamic Subject Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(subjects, id: \.self) { subject in
                                    Text(subject)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 18)
                                        .background(selectedTab == subject ? Color.white : Color.white.opacity(0.6))
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(selectedTab == subject ? Color.blue : Color.clear, lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            selectedTab = subject
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // List of Cards
                        VStack(spacing: 16) {
                            let filteredCards = cards.filter { selectedTab == "All subjects" || $0.subject == selectedTab }
                            
                            ForEach(filteredCards) { card in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(card.subject)
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.purple.opacity(0.1))
                                            .foregroundColor(.purple)
                                            .cornerRadius(6)
                                        
                                        Text("Due")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red.opacity(0.1))
                                            .foregroundColor(.red)
                                            .cornerRadius(6)
                                    }
                                    
                                    Text(card.question)
                                        .font(.body.bold())
                                    
                                    Button {
                                        selectedQuestion = card
                                        showAnswerPopup = true
                                    } label: {
                                        Text("Answer")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.blue)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            // Navigate to Create Page
            .navigationDestination(isPresented: $showAddCard) {
                AddFlashCardView()
            }
            // Answer Sheet (Popup)
            .sheet(isPresented: $showAnswerPopup) {
                if let card = selectedQuestion {
                    VStack(spacing: 25) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 40, height: 6)
                        
                        Text("Flash Card Answer")
                            .font(.title3.bold())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Question:").font(.caption).foregroundColor(.secondary)
                            Text(card.question).font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter your answer", text: $answerText)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        
                        Button {
                            showAnswerPopup = false
                            answerText = ""
                        } label: {
                            Text("Submit Answer")
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(30)
                    .presentationDetents([.medium])
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Ensures only our custom back button shows
    }
}

// Helper for the stat boxes
struct StatCardView: View {
    var title: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(18)
    }
}
