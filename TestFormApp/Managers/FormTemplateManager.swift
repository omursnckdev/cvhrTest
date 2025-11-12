//
//  FormTemplateManager.swift
//  TestFormApp
//
//  Manages loading and accessing form templates from JSON
//

import Foundation
import SwiftUI

@MainActor
class FormTemplateManager: ObservableObject {
    @Published var templates: [FormTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Dictionary of templates grouped by category
    var categories: [String: [FormTemplate]] {
        Dictionary(grouping: templates, by: { $0.category })
    }

    /// All unique category names
    var categoryNames: [String] {
        Array(Set(templates.map { $0.category })).sorted()
    }

    init() {
        loadTemplates()
    }

    /// Load templates from JSON file in bundle
    func loadTemplates() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "form_templates", withExtension: "json") else {
            errorMessage = "JSON dosyası bulunamadı"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            templates = try decoder.decode([FormTemplate].self, from: data)
            isLoading = false
        } catch {
            errorMessage = "JSON yükleme hatası: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Get template by ID
    func getTemplate(id: String) -> FormTemplate? {
        templates.first { $0.formId == id }
    }

    /// Get templates for a specific category
    func getTemplates(forCategory category: String) -> [FormTemplate] {
        templates.filter { $0.category == category }
    }

    /// Get templates for a specific category and level
    func getTemplates(forCategory category: String, level: String) -> [FormTemplate] {
        templates.filter { $0.category == category && $0.level == level }
    }

    /// Create a new filled form from a template
    func createFilledForm(from template: FormTemplate) -> FilledForm {
        let form = FilledForm(templateId: template.formId)

        // Initialize equipment info with default values
        var equipmentInfo: [String: String] = [:]
        for section in template.sections where section.type == .info {
            if let fields = section.fields {
                for field in fields {
                    if let defaultValue = field.defaultValue {
                        equipmentInfo[field.id] = defaultValue
                    } else {
                        equipmentInfo[field.id] = ""
                    }
                }
            }
        }
        form.equipmentInfo = equipmentInfo

        // Initialize checklist responses
        var checklistResponses: [String: ChecklistResponse] = [:]
        for section in template.sections where section.type == .checklist {
            var items: [Int: CheckStatus] = [:]
            if let templateItems = section.items {
                for item in templateItems {
                    items[item.number] = .unchecked
                }
            }
            checklistResponses[section.id] = ChecklistResponse(items: items)
        }
        form.checklistResponses = checklistResponses

        // Initialize attendees from template companies
        var attendees: [Attendee] = []
        for section in template.sections where section.type == .attendees {
            if let companies = section.companies {
                for company in companies {
                    attendees.append(Attendee(company: company))
                }
            }
        }
        form.attendees = attendees

        return form
    }

    /// Save template to JSON (for dependency management)
    func saveTemplate(_ template: FormTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else {
            return
        }

        templates[index] = template

        // Save to file
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(templates)

            // Get documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent("form_templates.json")

            try data.write(to: fileURL)
        } catch {
            errorMessage = "Kaydetme hatası: \(error.localizedDescription)"
        }
    }
}
