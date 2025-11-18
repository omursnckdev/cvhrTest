//
//  FilledForm.swift
//  TestFormApp
//
//  Model for filled form instances with SwiftData support
//

import Foundation
import SwiftData

/// Approval status for forms in the workflow
enum ApprovalStatus: String, Codable {
    case draft = "Taslak"                   // Created by Müteahhit, not yet saved
    case pendingMusavir = "Müşavir Bekliyor" // Saved by Müteahhit, waiting for Müşavir approval
    case pendingIsveren = "İşVeren Bekliyor" // Approved by Müşavir, waiting for İşVeren approval
    case approved = "Onaylandı"             // Fully approved by both Müşavir and İşVeren
}

/// A filled form instance
@Model
final class FilledForm {
    var id: UUID
    var templateId: String
    var createdDate: Date
    var lastModified: Date
    var equipmentInfoData: Data // JSON encoded [String: String]
    var checklistResponsesData: Data // JSON encoded [String: [Int: String]]
    var issuesData: Data // JSON encoded [IssueLog]
    var notesData: Data // JSON encoded [String]
    var attendeesData: Data // JSON encoded [Attendee]

    // Approval workflow properties
    var createdByUsername: String
    var approvalStatusRawValue: String
    var musavirApprovedBy: String?
    var musavirApprovedDate: Date?
    var isverenApprovedBy: String?
    var isverenApprovedDate: Date?

    /// Computed property for ApprovalStatus
    var approvalStatus: ApprovalStatus {
        get {
            ApprovalStatus(rawValue: approvalStatusRawValue) ?? .draft
        }
        set {
            approvalStatusRawValue = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        templateId: String,
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        equipmentInfo: [String: String] = [:],
        checklistResponses: [String: ChecklistResponse] = [:],
        issues: [IssueLog] = [],
        notes: [String] = [],
        attendees: [Attendee] = [],
        createdByUsername: String = "",
        approvalStatus: ApprovalStatus = .draft
    ) {
        self.id = id
        self.templateId = templateId
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.createdByUsername = createdByUsername
        self.approvalStatusRawValue = approvalStatus.rawValue

        // Encode initial data
        self.equipmentInfoData = (try? JSONEncoder().encode(equipmentInfo)) ?? Data()
        self.checklistResponsesData = (try? JSONEncoder().encode(checklistResponses)) ?? Data()
        self.issuesData = (try? JSONEncoder().encode(issues)) ?? Data()
        self.notesData = (try? JSONEncoder().encode(notes)) ?? Data()
        self.attendeesData = (try? JSONEncoder().encode(attendees)) ?? Data()
    }

    // Computed properties for easy access
    var equipmentInfo: [String: String] {
        get {
            (try? JSONDecoder().decode([String: String].self, from: equipmentInfoData)) ?? [:]
        }
        set {
            equipmentInfoData = (try? JSONEncoder().encode(newValue)) ?? Data()
            lastModified = Date()
        }
    }

    var checklistResponses: [String: ChecklistResponse] {
        get {
            (try? JSONDecoder().decode([String: ChecklistResponse].self, from: checklistResponsesData)) ?? [:]
        }
        set {
            checklistResponsesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            lastModified = Date()
        }
    }

    var issues: [IssueLog] {
        get {
            (try? JSONDecoder().decode([IssueLog].self, from: issuesData)) ?? []
        }
        set {
            issuesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            lastModified = Date()
        }
    }

    var notes: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: notesData)) ?? []
        }
        set {
            notesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            lastModified = Date()
        }
    }

    var attendees: [Attendee] {
        get {
            (try? JSONDecoder().decode([Attendee].self, from: attendeesData)) ?? []
        }
        set {
            attendeesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            lastModified = Date()
        }
    }

    /// Calculate completion percentage based on all checklist items
    func completionPercentage(template: FormTemplate) -> Double {
        var totalItems = 0
        var completedItems = 0

        for section in template.sections where section.type == .checklist {
            if let items = section.items {
                totalItems += items.count
                let responses = checklistResponses[section.id]?.items ?? [:]
                completedItems += responses.values.filter { $0 != .unchecked }.count
            }
        }

        guard totalItems > 0 else { return 0 }
        return Double(completedItems) / Double(totalItems) * 100
    }
}

/// Response data for a checklist section
struct ChecklistResponse: Codable {
    var items: [Int: CheckStatus]

    init(items: [Int: CheckStatus] = [:]) {
        self.items = items
    }
}

/// Issue log entry
struct IssueLog: Codable, Identifiable {
    let id: UUID
    var itemNumber: Int
    var description: String
    var responsibility: String
    var deadline: Date?
    var approved: Bool

    init(
        id: UUID = UUID(),
        itemNumber: Int,
        description: String = "",
        responsibility: String = "",
        deadline: Date? = nil,
        approved: Bool = false
    ) {
        self.id = id
        self.itemNumber = itemNumber
        self.description = description
        self.responsibility = responsibility
        self.deadline = deadline
        self.approved = approved
    }
}

/// Attendee information
struct Attendee: Codable, Identifiable {
    let id: UUID
    var company: String
    var name: String
    var date: Date?
    var signatureData: Data?

    init(
        id: UUID = UUID(),
        company: String,
        name: String = "",
        date: Date? = nil,
        signatureData: Data? = nil
    ) {
        self.id = id
        self.company = company
        self.name = name
        self.date = date
        self.signatureData = signatureData
    }
}
