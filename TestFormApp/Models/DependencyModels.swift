//
//  DependencyModels.swift
//  TestFormApp
//
//  Models for managing dependencies between checklist items
//

import Foundation

/// Represents a dependency between checklist items
struct ItemDependency: Codable, Identifiable {
    let id: UUID
    let type: DependencyType
    let targetItemNumbers: [Int]
    let message: String
    let severity: DependencySeverity

    init(
        id: UUID = UUID(),
        type: DependencyType,
        targetItemNumbers: [Int],
        message: String,
        severity: DependencySeverity
    ) {
        self.id = id
        self.type = type
        self.targetItemNumbers = targetItemNumbers
        self.message = message
        self.severity = severity
    }
}

/// Result of dependency validation
struct ValidationResult {
    let isValid: Bool
    let violations: [DependencyViolation]

    static var valid: ValidationResult {
        ValidationResult(isValid: true, violations: [])
    }

    static func invalid(violations: [DependencyViolation]) -> ValidationResult {
        ValidationResult(isValid: false, violations: violations)
    }
}

/// Details about a specific dependency violation
struct DependencyViolation: Identifiable {
    let id = UUID()
    let dependency: ItemDependency
    let currentItemNumber: Int
    let failedTargetNumbers: [Int]

    var message: String {
        dependency.message
    }

    var severity: DependencySeverity {
        dependency.severity
    }
}
