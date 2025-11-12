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
    @EnvironmentObject var firebaseManager: FirebaseManager

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
            // Shared Documents Section
            Section {
                NavigationLink {
                    SharedDocumentsView()
                } label: {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Onaylı Dökümanlar")
                                .font(.headline)

                            Text("Tüm onaylanmış testleri görüntüle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if firebaseManager.isAuthenticated {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }

            // Categories Section
            Section {
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
            } header: {
                Text("Test Kategorileri")
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
