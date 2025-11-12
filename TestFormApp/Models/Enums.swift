//
//  Enums.swift
//  TestFormApp
//
//  Core enums used throughout the application
//

import Foundation

/// Type of form section
enum SectionType: String, Codable {
    case info = "info"
    case checklist = "checklist"
    case issueLog = "issue_log"
    case attendees = "attendees"
    case notes = "notes"
}

/// Type of form field for equipment information
enum FieldType: String, Codable {
    case text = "text"
    case number = "number"
    case date = "date"
    case picker = "picker"
}

/// Checklist item status
enum CheckStatus: String, Codable, CaseIterable {
    case unchecked = ""
    case yes = "yes"
    case no = "no"
    case notApplicable = "na"

    var displayText: String {
        switch self {
        case .unchecked: return ""
        case .yes: return "EVET"
        case .no: return "HAYIR"
        case .notApplicable: return "N/A"
        }
    }

    var symbol: String {
        switch self {
        case .unchecked: return "circle"
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        case .notApplicable: return "minus.circle.fill"
        }
    }
}

/// Type of dependency between checklist items
enum DependencyType: String, Codable, CaseIterable {
    case requiresYes = "requires_yes"
    case requiresNo = "requires_no"
    case requiresNotNA = "requires_not_na"
    case requiresAnyYes = "requires_any_yes"
    case requiresAllYes = "requires_all_yes"
    case blockedIfYes = "blocked_if_yes"
    case blockedIfNo = "blocked_if_no"

    var displayName: String {
        switch self {
        case .requiresYes:
            return "Hedef maddeler EVET olmalı"
        case .requiresNo:
            return "Hedef maddeler HAYIR olmalı"
        case .requiresNotNA:
            return "Hedef maddeler N/A olmamalı"
        case .requiresAnyYes:
            return "En az biri EVET olmalı"
        case .requiresAllYes:
            return "Tümü EVET olmalı"
        case .blockedIfYes:
            return "Hedef EVET ise engelle"
        case .blockedIfNo:
            return "Hedef HAYIR ise engelle"
        }
    }

    var icon: String {
        switch self {
        case .requiresYes, .requiresAllYes:
            return "checkmark.circle"
        case .requiresNo:
            return "xmark.circle"
        case .requiresNotNA:
            return "circle.slash"
        case .requiresAnyYes:
            return "checkmark.circle.badge.questionmark"
        case .blockedIfYes, .blockedIfNo:
            return "hand.raised.fill"
        }
    }
}

/// Severity level of a dependency violation
enum DependencySeverity: String, Codable {
    case error = "error"
    case warning = "warning"
    case info = "info"

    var displayName: String {
        switch self {
        case .error: return "Hata"
        case .warning: return "Uyarı"
        case .info: return "Bilgi"
        }
    }
}
