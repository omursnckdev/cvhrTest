//
//  DependencyRow.swift
//  TestFormApp
//
//  Row component for displaying a dependency
//

import SwiftUI

struct DependencyRow: View {
    let dependency: ItemDependency

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: dependency.type.icon)
                    .foregroundStyle(Color.forSeverity(dependency.severity))

                Text(dependency.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // Severity badge
                Text(dependency.severity.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.forSeverity(dependency.severity).opacity(0.2))
                    .foregroundStyle(Color.forSeverity(dependency.severity))
                    .clipShape(Capsule())
            }

            // Target items
            HStack {
                Text("Hedef Maddeler:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(targetItemsText)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            // Message
            Text(dependency.message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var targetItemsText: String {
        dependency.targetItemNumbers.map { "\($0)" }.joined(separator: ", ")
    }
}

#Preview {
    VStack(spacing: 12) {
        DependencyRow(
            dependency: ItemDependency(
                type: .requiresYes,
                targetItemNumbers: [1, 2, 3],
                message: "Bu maddeler EVET olmalıdır",
                severity: .error
            )
        )

        DependencyRow(
            dependency: ItemDependency(
                type: .blockedIfNo,
                targetItemNumbers: [5],
                message: "5. madde HAYIR ise bu madde yapılamaz",
                severity: .warning
            )
        )
    }
    .padding()
}
