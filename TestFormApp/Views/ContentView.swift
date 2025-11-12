//
//  ContentView.swift
//  TestFormApp
//
//  Main entry view with navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var templateManager: FormTemplateManager
    @EnvironmentObject var dataManager: FilledFormDataManager

    var body: some View {
        NavigationStack {
            CategoryListView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FormTemplateManager())
        .environmentObject(FilledFormDataManager())
}
