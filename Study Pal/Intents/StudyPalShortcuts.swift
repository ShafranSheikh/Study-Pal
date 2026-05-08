import AppIntents


@available(iOS 16.4, *)
struct StudyPalShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Add a study task in \(.applicationName)",
                "New task in \(.applicationName)",
                "Create a task in \(.applicationName)"
            ],
            shortTitle: "Add Study Task",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
