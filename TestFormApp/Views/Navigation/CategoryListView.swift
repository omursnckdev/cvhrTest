//
//  CategoryListView.swift
//  TestFormApp
//
//  Displays list of all form categories
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var templateManager: FormTemplateManager
    @EnvironmentObject var dataManager: FilledFormDataManager

    private let categoryIcons: [String: String] = [
        "UPS": "bolt.fill",
        "Trafo": "poweroutlet.type.b.fill",
        "Jeneratör": "engine.combustion.fill",
        "RMU": "square.grid.3x3.square",
        "Panel": "rectangle.3.group.fill"
    ]

    var body: some View {
        Group {
            if templateManager.isLoading {
                ProgressView("Yükleniyor...")
            } else if templateManager.templates.isEmpty {
                emptyState
            } else {
                categoryList
            }
        }
        .navigationTitle("Test Formları")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: Text("Ayarlar")) {
                    Image(systemName: "gear")
                }
            }
        }
    }

    private var categoryList: some View {
        List {
            ForEach(templateManager.categoryNames, id: \.self) { category in
                NavigationLink {
                    TestLevelListView(category: category)
                } label: {
                    CategoryRow(
                        category: category,
                        icon: categoryIcons[category] ?? "folder.fill",
                        formCount: templateManager.getTemplates(forCategory: category).count
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Form Bulunamadı",
            systemImage: "doc.text.magnifyingglass",
            description: Text("Henüz hiç form template'i yüklenmemiş.")
        )
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
            .environmentObject(FormTemplateManager())
            .environmentObject(FilledFormDataManager())
    }
}
