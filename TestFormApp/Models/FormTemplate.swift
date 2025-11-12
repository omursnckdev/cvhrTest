//
//  FormTemplate.swift
//  TestFormApp
//
//  Template models for form structure loaded from JSON
//

import Foundation

/// Main template model for a test form
struct FormTemplate: Codable, Identifiable {
    let formId: String
    let category: String
    let level: String
    let title: String
    let sections: [FormSection]

    var id: String { formId }

    enum CodingKeys: String, CodingKey {
        case formId, category, level, title, sections
    }
}

/// A section within a form template
struct FormSection: Codable, Identifiable {
    let id: String
    let title: String
    let type: SectionType
    let fields: [FormField]?
    let items: [ChecklistTemplateItem]?
    let maxItems: Int?
    let companies: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, type, fields, items, maxItems, companies
    }
}

/// Field definition for equipment information section
struct FormField: Codable, Identifiable {
    let id: String
    let label: String
    let type: FieldType
    let defaultValue: String?
    let required: Bool?
    let options: [String]?

    var isRequired: Bool {
        required ?? false
    }

    enum CodingKeys: String, CodingKey {
        case id, label, type, defaultValue, required, options
    }
}

/// Template item for checklist section
struct ChecklistTemplateItem: Codable, Identifiable {
    let id: UUID
    let number: Int
    let description: String
    let controlMethod: String?
    let dependencies: [ItemDependency]

    init(
        id: UUID = UUID(),
        number: Int,
        description: String,
        controlMethod: String? = nil,
        dependencies: [ItemDependency] = []
    ) {
        self.id = id
        self.number = number
        self.description = description
        self.controlMethod = controlMethod
        self.dependencies = dependencies
    }

    enum CodingKeys: String, CodingKey {
        case id, number, description, controlMethod, dependencies
    }

    // Custom decoding to handle missing id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.number = try container.decode(Int.self, forKey: .number)
        self.description = try container.decode(String.self, forKey: .description)
        self.controlMethod = try? container.decode(String.self, forKey: .controlMethod)
        self.dependencies = (try? container.decode([ItemDependency].self, forKey: .dependencies)) ?? []
    }
}
