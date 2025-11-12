//
//  TestReportRow.swift
//  TestFormApp
//
//  Row component for displaying a filled form in the list
//

import SwiftUI

struct TestReportRow: View {
    let form: FilledForm
    let template: FormTemplate?

    private var completionPercentage: Double {
        guard let template = template else { return 0 }
        return form.completionPercentage(template: template)
    }

    private var isCompleted: Bool {
        completionPercentage >= 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template?.title ?? "Form")
                        .font(.headline)

                    Text(form.createdDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Status badge
                statusBadge
            }

            // Progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Tamamlanma")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(String(format: "%.0f%%", completionPercentage))
                        .font(.caption)
                        .fontWeight(.medium)
                }

                ProgressBar(percentage: completionPercentage)
                    .frame(height: 6)
            }

            // Equipment info
            if let equipmentName = form.equipmentInfo["equipment_name"], !equipmentName.isEmpty {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(equipmentName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var statusBadge: some View {
        Group {
            if isCompleted {
                Label("Tamamlandı", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green)
                    .clipShape(Capsule())
            } else {
                Label("Devam Ediyor", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.orange)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    let template = FormTemplate(
        formId: "ups_l2",
        category: "UPS",
        level: "L2",
        title: "UPS Panosu L2 Test",
        sections: []
    )

    let form1 = FilledForm(templateId: "ups_l2")
    let form2 = FilledForm(templateId: "ups_l2")

    return List {
        TestReportRow(form: form1, template: template)
        TestReportRow(form: form2, template: template)
    }
}
