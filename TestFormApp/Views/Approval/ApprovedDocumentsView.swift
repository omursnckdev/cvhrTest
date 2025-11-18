//
//  ApprovedDocumentsView.swift
//  TestFormApp
//
//  View for displaying all approved documents, grouped by category
//

import SwiftUI

struct ApprovedDocumentsView: View {
    @EnvironmentObject var formDataManager: FilledFormDataManager
    @EnvironmentObject var formTemplateManager: FormTemplateManager

    @State private var selectedCategory: String?

    var body: some View {
        NavigationView {
            List {
                if approvedForms.isEmpty {
                    ContentUnavailableView(
                        "Onaylanmış Form Yok",
                        systemImage: "checkmark.seal",
                        description: Text("Henüz onaylanmış form bulunmamaktadır.")
                    )
                } else {
                    // Category filter
                    Section("Kategori Filtresi") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryFilterButton(
                                    title: "Tümü",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }

                                ForEach(categories, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .listRowInsets(EdgeInsets())
                    }

                    // Grouped by category
                    ForEach(groupedForms.keys.sorted(), id: \.self) { category in
                        Section(category) {
                            ForEach(groupedForms[category] ?? []) { form in
                                if let template = formTemplateManager.getTemplate(id: form.templateId) {
                                    NavigationLink {
                                        FormDetailView(form: form, template: template, role: .isveren)
                                    } label: {
                                        ApprovedFormRow(form: form, template: template)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Onaylı Formlar")
        }
    }

    private var approvedForms: [FilledForm] {
        formDataManager.getApprovedForms()
    }

    private var filteredForms: [FilledForm] {
        if let category = selectedCategory {
            return approvedForms.filter { form in
                if let template = formTemplateManager.getTemplate(id: form.templateId) {
                    return template.category == category
                }
                return false
            }
        }
        return approvedForms
    }

    private var groupedForms: [String: [FilledForm]] {
        Dictionary(grouping: filteredForms) { form in
            formTemplateManager.getTemplate(id: form.templateId)?.category ?? "Diğer"
        }
    }

    private var categories: [String] {
        let allCategories = approvedForms.compactMap { form in
            formTemplateManager.getTemplate(id: form.templateId)?.category
        }
        return Array(Set(allCategories)).sorted()
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct ApprovedFormRow: View {
    let form: FilledForm
    let template: FormTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(template.title)
                .font(.headline)

            HStack {
                Label(template.level, systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let date = form.isverenApprovedDate {
                    Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            HStack {
                Text("Oluşturan: \(form.createdByUsername)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let musavirBy = form.musavirApprovedBy {
                    Text("Müşavir: \(musavirBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let isverenBy = form.isverenApprovedBy {
                Text("İşVeren: \(isverenBy)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ApprovedDocumentsView()
        .environmentObject(FilledFormDataManager())
        .environmentObject(FormTemplateManager())
}
