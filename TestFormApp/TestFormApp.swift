//
//  TestFormApp.swift
//  TestFormApp
//
//  Main application entry point
//

import SwiftUI
import SwiftData

@main
struct TestFormApp: App {
    // Template manager
    @StateObject private var templateManager = FormTemplateManager()

    // SwiftData model container
    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData with both FilledForm and User models
        do {
            let schema = Schema([FilledForm.self, User.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(templateManager)
                .environmentObject(createDataManager())
                .environmentObject(createUserManager())
                .modelContainer(modelContainer)
        }
    }

    private func createDataManager() -> FilledFormDataManager {
        let manager = FilledFormDataManager()
        manager.setup(container: modelContainer)
        return manager
    }

    @MainActor
    private func createUserManager() -> UserManager {
        let context = ModelContext(modelContainer)
        return UserManager(modelContext: context)
    }
}
