//
//  ApprovalListView.swift
//  TestFormApp
//
//  List of forms pending approval based on user role
//

import SwiftUI

struct ApprovalListView: View {
    @EnvironmentObject var formDataManager: FilledFormDataManager
    @EnvironmentObject var formTemplateManager: FormTemplateManager
    @EnvironmentObject var userManager: UserManager

    let role: UserRole

    var body: some View {
        List {
            if pendingForms.isEmpty {
                ContentUnavailableView(
                    "Onay Bekleyen Form Yok",
                    systemImage: "checkmark.circle",
                    description: Text("Şu anda onayınızı bekleyen form bulunmamaktadır.")
                )
            } else {
                ForEach(pendingForms) { form in
                    if let template = formTemplateManager.getTemplate(id: form.templateId) {
                        NavigationLink {
                            FormDetailView(form: form, template: template, role: role)
                        } label: {
                            ApprovalFormRow(form: form, template: template)
                        }
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pendingForms: [FilledForm] {
        switch role {
        case .musavir:
            return formDataManager.getFormsForMusavirApproval()
        case .isveren:
            return formDataManager.getFormsForIsverenApproval()
        case .muteahhit:
            return []
        }
    }

    private var navigationTitle: String {
        switch role {
        case .musavir:
            return "Müşavir Onayı Bekleyenler"
        case .isveren:
            return "İşVeren Onayı Bekleyenler"
        case .muteahhit:
            return "Formlarım"
        }
    }
}

struct ApprovalFormRow: View {
    let form: FilledForm
    let template: FormTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.title)
                    .font(.headline)

                Spacer()

                // Status badge
                Text(form.approvalStatus.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }

            HStack {
                Label(template.category, systemImage: "folder")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label(template.level, systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Oluşturan: \(form.createdByUsername)", systemImage: "person")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label(form.createdDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch form.approvalStatus {
        case .draft:
            return .gray
        case .pendingMusavir:
            return .orange
        case .pendingIsveren:
            return .blue
        case .approved:
            return .green
        }
    }
}

#Preview {
    NavigationView {
        ApprovalListView(role: .musavir)
            .environmentObject(FilledFormDataManager())
            .environmentObject(FormTemplateManager())
            .environmentObject(UserManager(modelContext: ModelContext(try! ModelContainer(for: User.self))))
    }
}
