import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

// MARK: - SubjectSummary
/// Aggregated view of all GradeEntry records for one subject.
struct SubjectSummary: Identifiable {
    let id = UUID()
    let name: String
    let averagePercentage: Double   // 0–100
    let target: Double              // latest target for this subject
    let recentEvent: String         // name of most recent entry
    let recentDate: String          // date of most recent entry
    let color: Color                // derived from colorHex of any entry
    let entries: [GradeEntry]       // all entries for this subject

    var ratio: Double { averagePercentage / 100 }
}

// MARK: - GradeViewModel
/// Manages grade CRUD operations against Firestore.
/// Path: users/{uid}/grades/{entryId}
class GradeViewModel: ObservableObject {

    // MARK: - Published State
    @Published var entries: [GradeEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchGrades()
    }

    deinit {
        listenerRegistration?.remove()
    }

    // MARK: - Collection Reference
    private func collectionRef(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("grades")
    }

    // MARK: - Fetch (Real-time)
    func fetchGrades() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("⚠️ GradeViewModel.fetchGrades: No authenticated user.")
            return
        }

        isLoading = true

        listenerRegistration = collectionRef(uid: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    if let error = error {
                        print("⚠️ GradeViewModel.fetchGrades: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    self?.entries = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: GradeEntry.self)
                    } ?? []

                    print("✅ GradeViewModel.fetchGrades: \(self?.entries.count ?? 0) entries loaded.")
                }
            }
    }

    // MARK: - Add Grade
    func addGrade(_ entry: GradeEntry, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(authError())
            return
        }

        guard !entry.subject.trimmingCharacters(in: .whitespaces).isEmpty,
              !entry.name.trimmingCharacters(in: .whitespaces).isEmpty,
              entry.maxScore > 0 else {
            completion?(validationError("Subject, Name and a non-zero Max Score are required."))
            return
        }

        do {
            try collectionRef(uid: uid).addDocument(from: entry) { error in
                if let error = error {
                    print("⚠️ GradeViewModel.addGrade: \(error.localizedDescription)")
                    completion?(error)
                } else {
                    print("✅ GradeViewModel.addGrade: Grade added.")
                    completion?(nil)
                }
            }
        } catch {
            print("⚠️ GradeViewModel.addGrade: Encoding error — \(error.localizedDescription)")
            completion?(error)
        }
    }

    // MARK: - Delete Grade
    func deleteGrade(_ entry: GradeEntry) {
        guard let uid = Auth.auth().currentUser?.uid,
              let entryId = entry.id else { return }

        collectionRef(uid: uid).document(entryId).delete { error in
            if let error = error {
                print("⚠️ GradeViewModel.deleteGrade: \(error.localizedDescription)")
            } else {
                print("✅ GradeViewModel.deleteGrade: Entry \(entryId) deleted.")
            }
        }
    }

    // MARK: - Computed: Subject Summaries
    /// Groups all GradeEntry records by subject and computes per-subject averages.
    var subjectSummaries: [SubjectSummary] {
        let grouped = Dictionary(grouping: entries, by: { $0.subject })
        return grouped.map { subject, subjectEntries in
            let avgPct = subjectEntries.reduce(0.0) { $0 + $1.percentage } / Double(subjectEntries.count)
            // Use the most recent entry (first, since sorted desc) for event/date/target/color
            let latest = subjectEntries.first!
            return SubjectSummary(
                name: subject,
                averagePercentage: avgPct,
                target: latest.target,
                recentEvent: latest.name,
                recentDate: latest.date,
                color: Color(hex: latest.colorHex) ?? .blue,
                entries: subjectEntries
            )
        }
        .sorted { $0.name < $1.name }
    }

    // MARK: - Computed: Overall Average
    /// Mean percentage across all grade entries.
    var overallAverage: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0.0) { $0 + $1.percentage } / Double(entries.count)
    }

    // MARK: - Error Helpers
    private func authError() -> NSError {
        NSError(domain: "GradeViewModel", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
    }

    private func validationError(_ msg: String) -> NSError {
        NSError(domain: "GradeViewModel", code: 400,
                userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

