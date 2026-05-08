import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class FlashCardViewModel: ObservableObject {

    //Published State
    @Published var cards: [FlashCardItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchCards()
    }

    deinit {
        listenerRegistration?.remove()
    }

    // Collection Reference
    private func collectionRef(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("flashCards")
    }

    func fetchCards() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("FlashCardViewModel.fetchCards: No authenticated user.")
            return
        }

        isLoading = true

        listenerRegistration = collectionRef(uid: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    if let error = error {
                        print("FlashCardViewModel.fetchCards: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    self?.cards = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: FlashCardItem.self)
                    } ?? []

                    print("FlashCardViewModel.fetchCards: \(self?.cards.count ?? 0) cards loaded.")
                }
            }
    }

    //Add Card
    func addCard(question: String, answer: String, subject: String, dueDate: String,
                 completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(authError())
            return
        }

        guard !question.trimmingCharacters(in: .whitespaces).isEmpty,
              !subject.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion?(validationError("Question and Subject are required."))
            return
        }

        let card = FlashCardItem(
            question: question,
            answer: answer,
            subject: subject,
            dueDate: dueDate
        )

        do {
            try collectionRef(uid: uid).addDocument(from: card) { error in
                if let error = error {
                    print("FlashCardViewModel.addCard: \(error.localizedDescription)")
                    completion?(error)
                } else {
                    print("FlashCardViewModel.addCard: Card added.")
                    completion?(nil)
                }
            }
        } catch {
            print("FlashCardViewModel.addCard: Encoding error — \(error.localizedDescription)")
            completion?(error)
        }
    }

    // Delete Card
    func deleteCard(_ card: FlashCardItem) {
        guard let uid = Auth.auth().currentUser?.uid,
              let cardId = card.id else { return }

        collectionRef(uid: uid).document(cardId).delete { error in
            if let error = error {
                print("FlashCardViewModel.deleteCard: \(error.localizedDescription)")
            } else {
                print("FlashCardViewModel.deleteCard: Card \(cardId) deleted.")
            }
        }
    }

    //  Mark as Answered
    func markAsAnswered(_ card: FlashCardItem) {
        guard let uid = Auth.auth().currentUser?.uid,
              let cardId = card.id else { return }

        collectionRef(uid: uid).document(cardId).updateData(["isAnswered": true]) { error in
            if let error = error {
                print("FlashCardViewModel.markAsAnswered: \(error.localizedDescription)")
            }
        }
    }

    //  Save User's Answer
    func saveAnswer(for card: FlashCardItem, answer: String,
                    completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid,
              let cardId = card.id else {
            completion?(authError())
            return
        }

        let data: [String: Any] = [
            "answer": answer.trimmingCharacters(in: .whitespaces),
            "isAnswered": true
        ]

        collectionRef(uid: uid).document(cardId).updateData(data) { error in
            if let error = error {
                print("FlashCardViewModel.saveAnswer: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("FlashCardViewModel.saveAnswer: Answer saved for card \(cardId).")
                completion?(nil)
            }
        }
    }


    // Computed Stats
    var totalCards: Int { cards.count }
    var answeredCards: Int { cards.filter { $0.isAnswered }.count }
    var completionPercentage: Int {
        guard totalCards > 0 else { return 0 }
        return Int((Double(answeredCards) / Double(totalCards)) * 100)
    }
    var dueTodayCount: Int {
        let today = formattedToday()
        return cards.filter { $0.dueDate == today }.count
    }

    private func formattedToday() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    // Error Helpers
    private func authError() -> NSError {
        NSError(domain: "FlashCardViewModel", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
    }

    private func validationError(_ msg: String) -> NSError {
        NSError(domain: "FlashCardViewModel", code: 400,
                userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
