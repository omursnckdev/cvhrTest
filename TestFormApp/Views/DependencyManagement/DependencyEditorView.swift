//
//  DependencyEditorView.swift
//  TestFormApp
//
//  Editor view for managing all dependencies in a template
//

import SwiftUI

struct DependencyEditorView: View {
    @EnvironmentObject var templateManager: FormTemplateManager

    let template: FormTemplate

    @State private var localTemplate: FormTemplate
    @State private var hasChanges = false
    @State private var showingSaveAlert = false

    init(template: FormTemplate) {
        self.template = template
        _localTemplate = State(initialValue: template)
    }

    var body: some View {
        List {
            ForEach(checklistSections) { section in
                Section {
                    if let items = section.items {
                        ForEach(items) { item in
                            NavigationLink {
                                ItemDependencyEditor(
                                    item: item,
                                    allItems: items,
                                    onUpdate: { updatedItem in
                                        updateItem(updatedItem, in: section.id)
                                    }
                                )
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Madde \(item.number)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)

                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if !item.dependencies.isEmpty {
                                        Label("\(item.dependencies.count)", systemImage: "link.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text(section.title)
                }
            }
        }
        .navigationTitle("Bağımlılık Yönetimi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    saveTemplate()
                } label: {
                    Label("Kaydet", systemImage: "square.and.arrow.down")
                }
                .disabled(!hasChanges)
            }
        }
        .alert("Kaydedildi", isPresented: $showingSaveAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Bağımlılıklar başarıyla kaydedildi")
        }
    }

    private var checklistSections: [FormSection] {
        localTemplate.sections.filter { $0.type == .checklist }
    }

    private func updateItem(_ updatedItem: ChecklistTemplateItem, in sectionId: String) {
        var sections = localTemplate.sections

        if let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) {
            var section = sections[sectionIndex]

            if var items = section.items {
                if let itemIndex = items.firstIndex(where: { $0.id == updatedItem.id }) {
                    items[itemIndex] = updatedItem

                    // Update section with new items
                    section = FormSection(
                        id: section.id,
                        title: section.title,
                        type: section.type,
                        fields: section.fields,
                        items: items,
                        maxItems: section.maxItems,
                        companies: section.companies
                    )

                    sections[sectionIndex] = section

                    localTemplate = FormTemplate(
                        formId: localTemplate.formId,
                        category: localTemplate.category,
                        level: localTemplate.level,
                        title: localTemplate.title,
                        sections: sections
                    )

                    hasChanges = true
                }
            }
        }
    }

    private func saveTemplate() {
        templateManager.saveTemplate(localTemplate)
        hasChanges = false
        showingSaveAlert = true
    }
}

#Preview {
    NavigationStack {
        DependencyEditorView(
            template: FormTemplate(
                formId: "test",
                category: "UPS",
                level: "L2",
                title: "Test Template",
                sections: [
                    FormSection(
                        id: "checklist",
                        title: "Checklist",
                        type: .checklist,
                        fields: nil,
                        items: [
                            ChecklistTemplateItem(number: 1, description: "Item 1"),
                            ChecklistTemplateItem(number: 2, description: "Item 2")
                        ],
                        maxItems: nil,
                        companies: nil
                    )
                ]
            )
        )
        .environmentObject(FormTemplateManager())
    }
}
