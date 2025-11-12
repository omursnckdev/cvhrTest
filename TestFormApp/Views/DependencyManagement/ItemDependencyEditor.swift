//
//  ItemDependencyEditor.swift
//  TestFormApp
//
//  Editor view for managing dependencies of a specific item
//

import SwiftUI

struct ItemDependencyEditor: View {
    @Environment(\.dismiss) private var dismiss

    let item: ChecklistTemplateItem
    let allItems: [ChecklistTemplateItem]
    let onUpdate: (ChecklistTemplateItem) -> Void

    @State private var localItem: ChecklistTemplateItem
    @State private var showingAddSheet = false

    init(
        item: ChecklistTemplateItem,
        allItems: [ChecklistTemplateItem],
        onUpdate: @escaping (ChecklistTemplateItem) -> Void
    ) {
        self.item = item
        self.allItems = allItems
        self.onUpdate = onUpdate
        _localItem = State(initialValue: item)
    }

    var body: some View {
        List {
            // Item info
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Madde \(localItem.number)")
                        .font(.headline)

                    Text(localItem.description)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    if let method = localItem.controlMethod {
                        Label(method, systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Madde Bilgisi")
            }

            // Dependencies
            Section {
                if localItem.dependencies.isEmpty {
                    ContentUnavailableView(
                        "Bağımlılık Yok",
                        systemImage: "link.circle",
                        description: Text("Bu madde için henüz bağımlılık tanımlanmamış")
                    )
                } else {
                    ForEach(localItem.dependencies) { dependency in
                        DependencyRow(dependency: dependency)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteDependency(dependency)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                    }
                }
            } header: {
                Text("Bağımlılıklar (\(localItem.dependencies.count))")
            }
        }
        .navigationTitle("Bağımlılık Düzenleyici")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Kapat") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDependencySheet(
                availableItems: allItems,
                currentItemNumber: localItem.number,
                onAdd: { newDependency in
                    addDependency(newDependency)
                }
            )
        }
    }

    private func addDependency(_ dependency: ItemDependency) {
        var updatedItem = localItem
        updatedItem = ChecklistTemplateItem(
            id: updatedItem.id,
            number: updatedItem.number,
            description: updatedItem.description,
            controlMethod: updatedItem.controlMethod,
            dependencies: updatedItem.dependencies + [dependency]
        )
        localItem = updatedItem
        onUpdate(updatedItem)
    }

    private func deleteDependency(_ dependency: ItemDependency) {
        var updatedItem = localItem
        updatedItem = ChecklistTemplateItem(
            id: updatedItem.id,
            number: updatedItem.number,
            description: updatedItem.description,
            controlMethod: updatedItem.controlMethod,
            dependencies: updatedItem.dependencies.filter { $0.id != dependency.id }
        )
        localItem = updatedItem
        onUpdate(updatedItem)
    }
}

#Preview {
    NavigationStack {
        ItemDependencyEditor(
            item: ChecklistTemplateItem(
                number: 2,
                description: "İş yapım yöntemi (İYY) onaylanmıştır.",
                controlMethod: "Gözle Kontrol",
                dependencies: [
                    ItemDependency(
                        type: .requiresYes,
                        targetItemNumbers: [1],
                        message: "1. madde EVET olmalı",
                        severity: .error
                    )
                ]
            ),
            allItems: [
                ChecklistTemplateItem(number: 1, description: "Saha uygulama projeleri onaylanmıştır."),
                ChecklistTemplateItem(number: 2, description: "İş yapım yöntemi (İYY) onaylanmıştır.")
            ],
            onUpdate: { _ in }
        )
    }
}
