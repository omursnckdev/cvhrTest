//
//  ChecklistSectionView.swift
//  TestFormApp
//
//  Checklist section with dependency validation
//

import SwiftUI

struct ChecklistSectionView: View {
    @ObservedObject var form: FilledForm
    let sectionId: String
    let items: [ChecklistTemplateItem]

    @StateObject private var validator = DependencyValidator()
    @State private var validationAlert: ValidationAlertData?
    @State private var showingValidationAlert = false

    private var currentResponses: [Int: CheckStatus] {
        form.checklistResponses[sectionId]?.items ?? [:]
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                ChecklistItemRow(
                    item: item,
                    status: binding(for: item.number),
                    isDisabled: validator.isItemDisabled(
                        itemNumber: item.number,
                        currentResponses: currentResponses,
                        items: items
                    ),
                    onStatusChange: { newStatus in
                        handleStatusChange(itemNumber: item.number, newStatus: newStatus)
                    }
                )
            }
        }
        .alert(
            validationAlert?.title ?? "Uyarı",
            isPresented: $showingValidationAlert,
            presenting: validationAlert
        ) { alert in
            Button("Tamam", role: .cancel) {
                validationAlert = nil
            }

            if alert.canContinue {
                Button("Yine de Devam Et") {
                    applyChange(itemNumber: alert.itemNumber, newStatus: alert.newStatus)
                    validationAlert = nil
                }
            }
        } message: { alert in
            Text(alert.message)
        }
    }

    private func binding(for itemNumber: Int) -> Binding<CheckStatus> {
        Binding(
            get: {
                currentResponses[itemNumber] ?? .unchecked
            },
            set: { _ in
                // Status changes are handled by onStatusChange
            }
        )
    }

    private func handleStatusChange(itemNumber: Int, newStatus: CheckStatus) {
        let result = validator.validate(
            itemNumber: itemNumber,
            newStatus: newStatus,
            currentResponses: currentResponses,
            items: items
        )

        if result.isValid {
            applyChange(itemNumber: itemNumber, newStatus: newStatus)
        } else {
            // Show validation alert
            let errorViolations = result.violations.filter { $0.severity == .error }
            let warningViolations = result.violations.filter { $0.severity == .warning }

            if !errorViolations.isEmpty {
                // Critical errors - must fix
                let messages = errorViolations.map { violation in
                    "• \(violation.message)"
                }.joined(separator: "\n")

                validationAlert = ValidationAlertData(
                    title: "Bağımlılık Hatası",
                    message: "Bu değişiklik yapılamaz:\n\n\(messages)",
                    canContinue: false,
                    itemNumber: itemNumber,
                    newStatus: newStatus
                )
                showingValidationAlert = true
            } else if !warningViolations.isEmpty {
                // Warnings - can continue
                let messages = warningViolations.map { violation in
                    "• \(violation.message)"
                }.joined(separator: "\n")

                validationAlert = ValidationAlertData(
                    title: "Uyarı",
                    message: "Dikkat:\n\n\(messages)\n\nDevam etmek istiyor musunuz?",
                    canContinue: true,
                    itemNumber: itemNumber,
                    newStatus: newStatus
                )
                showingValidationAlert = true
            }
        }
    }

    private func applyChange(itemNumber: Int, newStatus: CheckStatus) {
        var responses = form.checklistResponses
        var sectionResponse = responses[sectionId] ?? ChecklistResponse()
        sectionResponse.items[itemNumber] = newStatus
        responses[sectionId] = sectionResponse
        form.checklistResponses = responses
    }
}

struct ValidationAlertData {
    let title: String
    let message: String
    let canContinue: Bool
    let itemNumber: Int
    let newStatus: CheckStatus
}

#Preview {
    let form = FilledForm(templateId: "test")

    let items = [
        ChecklistTemplateItem(
            number: 1,
            description: "Saha uygulama projeleri onaylanmıştır.",
            controlMethod: "Gözle Kontrol"
        ),
        ChecklistTemplateItem(
            number: 2,
            description: "İş yapım yöntemi (İYY) onaylanmıştır.",
            controlMethod: "Gözle Kontrol",
            dependencies: [
                ItemDependency(
                    type: .requiresYes,
                    targetItemNumbers: [1],
                    message: "Önce 1. madde EVET olmalı",
                    severity: .error
                )
            ]
        )
    ]

    return ChecklistSectionView(
        form: form,
        sectionId: "test_section",
        items: items
    )
    .padding()
}
