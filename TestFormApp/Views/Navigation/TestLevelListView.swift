//
//  TestLevelListView.swift
//  TestFormApp
//
//  Displays test levels (L1, L2, L3) for a category and filled forms
//

import SwiftUI

struct TestLevelListView: View {
    let category: String

    @EnvironmentObject var templateManager: FormTemplateManager
    @EnvironmentObject var dataManager: FilledFormDataManager

    @State private var selectedTemplate: FormTemplate?
    @State private var showingNewForm = false

    private var templates: [FormTemplate] {
        templateManager.getTemplates(forCategory: category)
    }

    private var levels: [String] {
        let allLevels = templates.map { $0.level }
        return Array(Set(allLevels)).sorted()
    }

    var body: some View {
        List {
            ForEach(levels, id: \.self) { level in
                Section {
                    let levelTemplates = templates.filter { $0.level == level }

                    ForEach(levelTemplates) { template in
                        VStack(alignment: .leading, spacing: 12) {
                            // Template header
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(template.title)
                                        .font(.headline)

                                    Text("\(level) Seviye")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button {
                                    selectedTemplate = template
                                    showingNewForm = true
                                } label: {
                                    Label("Yeni Test", systemImage: "plus.circle.fill")
                                        .font(.subheadline)
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            // Existing forms for this template
                            let existingForms = dataManager.getForms(forTemplateId: template.formId)

                            if !existingForms.isEmpty {
                                Divider()

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mevcut Testler")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)

                                    ForEach(existingForms) { form in
                                        NavigationLink {
                                            DynamicFormView(form: form, template: template)
                                        } label: {
                                            TestReportRow(form: form, template: template)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Seviye \(level)")
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingNewForm) {
            if let template = selectedTemplate {
                NavigationStack {
                    DynamicFormView(
                        form: templateManager.createFilledForm(from: template),
                        template: template,
                        isNew: true
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TestLevelListView(category: "UPS")
            .environmentObject(FormTemplateManager())
            .environmentObject(FilledFormDataManager())
    }
}
