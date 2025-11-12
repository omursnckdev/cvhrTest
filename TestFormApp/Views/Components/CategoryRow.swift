//
//  CategoryRow.swift
//  TestFormApp
//
//  Row component for displaying a category in the list
//

import SwiftUI

struct CategoryRow: View {
    let category: String
    let icon: String
    let formCount: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.headline)

                Text("\(formCount) form")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CategoryRow(category: "UPS", icon: "bolt.fill", formCount: 3)
        CategoryRow(category: "Trafo", icon: "poweroutlet.type.b.fill", formCount: 5)
        CategoryRow(category: "Jeneratör", icon: "engine.combustion.fill", formCount: 2)
    }
}
