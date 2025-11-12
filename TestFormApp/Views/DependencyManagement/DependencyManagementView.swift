//
//  DependencyManagementView.swift
//  TestFormApp
//
//  Main view for dependency management accessed from settings
//

import SwiftUI

struct DependencyManagementView: View {
    @EnvironmentObject var templateManager: FormTemplateManager

    var body: some View {
        List {
            if templateManager.templates.isEmpty {
                ContentUnavailableView(
                    "Template Bulunamadı",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Henüz düzenlenebilecek template bulunmamaktadır")
                )
            } else {
                ForEach(templateManager.templates) { template in
                    NavigationLink {
                        DependencyEditorView(template: template)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.title)
                                .font(.headline)

                            HStack {
                                Text(template.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())

                                Text("Seviye \(template.level)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            // Count dependencies
                            let depCount = countDependencies(in: template)
                            if depCount > 0 {
                                Label("\(depCount) bağımlılık", systemImage: "link.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Bağımlılık Yönetimi")
    }

    private func countDependencies(in template: FormTemplate) -> Int {
        var count = 0
        for section in template.sections where section.type == .checklist {
            if let items = section.items {
                for item in items {
                    count += item.dependencies.count
                }
            }
        }
        return count
    }
}

#Preview {
    NavigationStack {
        DependencyManagementView()
            .environmentObject(FormTemplateManager())
    }
}
