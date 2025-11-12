//
//  ChecklistItemRow.swift
//  TestFormApp
//
//  Row for a single checklist item with dependency support
//

import SwiftUI

struct ChecklistItemRow: View {
    let item: ChecklistTemplateItem
    @Binding var status: CheckStatus
    let isDisabled: Bool
    let onStatusChange: (CheckStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Item header
            HStack(alignment: .top) {
                // Item number
                Text("\(item.number).")
                    .font(.headline)
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                    .frame(width: 30, alignment: .leading)

                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(isDisabled ? .secondary : .primary)

                    if let controlMethod = item.controlMethod {
                        Label(controlMethod, systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }

                Spacer()
            }

            // Status picker
            Picker("Durum", selection: $status) {
                ForEach(CheckStatus.allCases, id: \.self) { checkStatus in
                    Text(checkStatus.displayText)
                        .tag(checkStatus)
                }
            }
            .pickerStyle(.segmented)
            .disabled(isDisabled)
            .onChange(of: status) { oldValue, newValue in
                if !isDisabled {
                    onStatusChange(newValue)
                }
            }

            // Dependency indicators
            if !item.dependencies.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Bağımlılıklar var", systemImage: "link.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    ForEach(item.dependencies) { dependency in
                        HStack(spacing: 6) {
                            Image(systemName: dependency.type.icon)
                                .font(.caption2)

                            Text(dependencyText(for: dependency))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // Disabled indicator
            if isDisabled {
                Label("Bu madde şu anda aktif değil", systemImage: "hand.raised.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.1)
        }

        switch status {
        case .unchecked:
            return Color(.systemBackground)
        case .yes:
            return Color.green.opacity(0.1)
        case .no:
            return Color.red.opacity(0.1)
        case .notApplicable:
            return Color.gray.opacity(0.1)
        }
    }

    private func dependencyText(for dependency: ItemDependency) -> String {
        let targets = dependency.targetItemNumbers.map { "\($0)" }.joined(separator: ", ")
        return "\(dependency.type.displayName): Maddeler \(targets)"
    }
}

#Preview {
    VStack(spacing: 16) {
        // Normal item
        ChecklistItemRow(
            item: ChecklistTemplateItem(
                number: 1,
                description: "Saha uygulama projeleri onaylanmıştır.",
                controlMethod: "Gözle Kontrol"
            ),
            status: .constant(.unchecked),
            isDisabled: false,
            onStatusChange: { _ in }
        )

        // Item with dependency
        ChecklistItemRow(
            item: ChecklistTemplateItem(
                number: 2,
                description: "İş yapım yöntemi (İYY) onaylanmıştır.",
                controlMethod: "Gözle Kontrol",
                dependencies: [
                    ItemDependency(
                        type: .requiresYes,
                        targetItemNumbers: [1],
                        message: "1. madde EVET olmalı",
                        severity: .error
                    )
                ]
            ),
            status: .constant(.yes),
            isDisabled: false,
            onStatusChange: { _ in }
        )

        // Disabled item
        ChecklistItemRow(
            item: ChecklistTemplateItem(
                number: 3,
                description: "Ekipman montajı tamamlanmıştır.",
                controlMethod: "Gözle Kontrol"
            ),
            status: .constant(.unchecked),
            isDisabled: true,
            onStatusChange: { _ in }
        )
    }
    .padding()
}
