//
//  DependencyValidator.swift
//  TestFormApp
//
//  Validates dependencies between checklist items
//

import Foundation

@MainActor
class DependencyValidator: ObservableObject {
    /// Validate a status change for a specific item
    func validate(
        itemNumber: Int,
        newStatus: CheckStatus,
        currentResponses: [Int: CheckStatus],
        items: [ChecklistTemplateItem]
    ) -> ValidationResult {
        guard let item = items.first(where: { $0.number == itemNumber }) else {
            return .valid
        }

        var violations: [DependencyViolation] = []

        // Check all dependencies for this item
        for dependency in item.dependencies {
            if let violation = checkDependency(
                dependency: dependency,
                currentItemNumber: itemNumber,
                newStatus: newStatus,
                currentResponses: currentResponses
            ) {
                violations.append(violation)
            }
        }

        return violations.isEmpty ? .valid : .invalid(violations: violations)
    }

    /// Validate all items in the checklist
    func validateAll(
        currentResponses: [Int: CheckStatus],
        items: [ChecklistTemplateItem]
    ) -> [DependencyViolation] {
        var allViolations: [DependencyViolation] = []

        for item in items {
            let currentStatus = currentResponses[item.number] ?? .unchecked
            let result = validate(
                itemNumber: item.number,
                newStatus: currentStatus,
                currentResponses: currentResponses,
                items: items
            )
            allViolations.append(contentsOf: result.violations)
        }

        return allViolations
    }

    /// Check if an item should be disabled based on dependencies
    func isItemDisabled(
        itemNumber: Int,
        currentResponses: [Int: CheckStatus],
        items: [ChecklistTemplateItem]
    ) -> Bool {
        guard let item = items.first(where: { $0.number == itemNumber }) else {
            return false
        }

        // Item is disabled if any error-level dependency is not satisfied
        for dependency in item.dependencies where dependency.severity == .error {
            let satisfied = isDependencySatisfied(
                dependency: dependency,
                currentResponses: currentResponses
            )
            if !satisfied {
                return true
            }
        }

        return false
    }

    /// Check a single dependency
    private func checkDependency(
        dependency: ItemDependency,
        currentItemNumber: Int,
        newStatus: CheckStatus,
        currentResponses: [Int: CheckStatus]
    ) -> DependencyViolation? {
        let targetStatuses = dependency.targetItemNumbers.compactMap { currentResponses[$0] }
        var failedTargets: [Int] = []

        let isSatisfied: Bool

        switch dependency.type {
        case .requiresYes:
            // All target items must be YES
            isSatisfied = dependency.targetItemNumbers.allSatisfy { itemNum in
                let status = currentResponses[itemNum] ?? .unchecked
                if status != .yes {
                    failedTargets.append(itemNum)
                    return false
                }
                return true
            }

        case .requiresNo:
            // All target items must be NO
            isSatisfied = dependency.targetItemNumbers.allSatisfy { itemNum in
                let status = currentResponses[itemNum] ?? .unchecked
                if status != .no {
                    failedTargets.append(itemNum)
                    return false
                }
                return true
            }

        case .requiresNotNA:
            // Target items must not be N/A
            isSatisfied = dependency.targetItemNumbers.allSatisfy { itemNum in
                let status = currentResponses[itemNum] ?? .unchecked
                if status == .notApplicable {
                    failedTargets.append(itemNum)
                    return false
                }
                return true
            }

        case .requiresAnyYes:
            // At least one target must be YES
            isSatisfied = dependency.targetItemNumbers.contains { itemNum in
                currentResponses[itemNum] == .yes
            }
            if !isSatisfied {
                failedTargets = dependency.targetItemNumbers
            }

        case .requiresAllYes:
            // All targets must be YES
            isSatisfied = dependency.targetItemNumbers.allSatisfy { itemNum in
                let status = currentResponses[itemNum] ?? .unchecked
                if status != .yes {
                    failedTargets.append(itemNum)
                    return false
                }
                return true
            }

        case .blockedIfYes:
            // Current item is blocked if any target is YES
            let hasYes = dependency.targetItemNumbers.contains { itemNum in
                currentResponses[itemNum] == .yes
            }
            isSatisfied = !hasYes
            if !isSatisfied {
                failedTargets = dependency.targetItemNumbers.filter {
                    currentResponses[$0] == .yes
                }
            }

        case .blockedIfNo:
            // Current item is blocked if any target is NO
            let hasNo = dependency.targetItemNumbers.contains { itemNum in
                currentResponses[itemNum] == .no
            }
            isSatisfied = !hasNo
            if !isSatisfied {
                failedTargets = dependency.targetItemNumbers.filter {
                    currentResponses[$0] == .no
                }
            }
        }

        if !isSatisfied {
            return DependencyViolation(
                dependency: dependency,
                currentItemNumber: currentItemNumber,
                failedTargetNumbers: failedTargets
            )
        }

        return nil
    }

    /// Check if a dependency is satisfied
    private func isDependencySatisfied(
        dependency: ItemDependency,
        currentResponses: [Int: CheckStatus]
    ) -> Bool {
        switch dependency.type {
        case .requiresYes:
            return dependency.targetItemNumbers.allSatisfy {
                currentResponses[$0] == .yes
            }

        case .requiresNo:
            return dependency.targetItemNumbers.allSatisfy {
                currentResponses[$0] == .no
            }

        case .requiresNotNA:
            return dependency.targetItemNumbers.allSatisfy {
                currentResponses[$0] != .notApplicable
            }

        case .requiresAnyYes:
            return dependency.targetItemNumbers.contains {
                currentResponses[$0] == .yes
            }

        case .requiresAllYes:
            return dependency.targetItemNumbers.allSatisfy {
                currentResponses[$0] == .yes
            }

        case .blockedIfYes:
            return !dependency.targetItemNumbers.contains {
                currentResponses[$0] == .yes
            }

        case .blockedIfNo:
            return !dependency.targetItemNumbers.contains {
                currentResponses[$0] == .no
            }
        }
    }
}
