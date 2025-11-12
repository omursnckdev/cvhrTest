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
        // Configure SwiftData
        do {
            let schema = Schema([FilledForm.self])
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
                .modelContainer(modelContainer)
        }
    }

    private func createDataManager() -> FilledFormDataManager {
        let manager = FilledFormDataManager()
        manager.setup(container: modelContainer)
        return manager
    }
}
