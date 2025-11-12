//
//  IssueLogSectionView.swift
//  TestFormApp
//
//  Section for managing issue logs
//

import SwiftUI

struct IssueLogSectionView: View {
    @ObservedObject var form: FilledForm
    let maxItems: Int

    @State private var expandedIssues: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Issues list
            if form.issues.isEmpty {
                emptyState
            } else {
                ForEach(form.issues) { issue in
                    IssueRow(
                        issue: issue,
                        isExpanded: expandedIssues.contains(issue.id),
                        onToggleExpand: {
                            toggleExpanded(issue.id)
                        },
                        onUpdate: { updatedIssue in
                            updateIssue(updatedIssue)
                        },
                        onDelete: {
                            deleteIssue(issue)
                        }
                    )
                }
            }

            // Add button
            if form.issues.count < maxItems {
                Button {
                    addNewIssue()
                } label: {
                    Label("Yeni Problem Ekle", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Text("Maksimum \(maxItems) problem eklenebilir")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .foregroundStyle(.green)

            Text("Henüz problem kaydı yok")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func addNewIssue() {
        var issues = form.issues
        let newIssue = IssueLog(itemNumber: 0)
        issues.append(newIssue)
        form.issues = issues
        expandedIssues.insert(newIssue.id)
    }

    private func updateIssue(_ updatedIssue: IssueLog) {
        var issues = form.issues
        if let index = issues.firstIndex(where: { $0.id == updatedIssue.id }) {
            issues[index] = updatedIssue
            form.issues = issues
        }
    }

    private func deleteIssue(_ issue: IssueLog) {
        var issues = form.issues
        issues.removeAll { $0.id == issue.id }
        form.issues = issues
        expandedIssues.remove(issue.id)
    }

    private func toggleExpanded(_ id: UUID) {
        if expandedIssues.contains(id) {
            expandedIssues.remove(id)
        } else {
            expandedIssues.insert(id)
        }
    }
}

struct IssueRow: View {
    let issue: IssueLog
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onUpdate: (IssueLog) -> Void
    let onDelete: () -> Void

    @State private var localIssue: IssueLog

    init(
        issue: IssueLog,
        isExpanded: Bool,
        onToggleExpand: @escaping () -> Void,
        onUpdate: @escaping (IssueLog) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.issue = issue
        self.isExpanded = isExpanded
        self.onToggleExpand = onToggleExpand
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _localIssue = State(initialValue: issue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Text("Problem #\(localIssue.itemNumber > 0 ? "\(localIssue.itemNumber)" : "?")")
                    .font(.headline)

                Spacer()

                Button {
                    onToggleExpand()
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(.blue)
                }

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .foregroundStyle(.red)
                }
            }

            if isExpanded {
                Divider()

                // Fields
                VStack(spacing: 12) {
                    // Item number
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Madde No")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Madde numarası", value: $localIssue.itemNumber, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Açıklama")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $localIssue.description)
                            .frame(height: 80)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Responsibility
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sorumluluk")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Sorumlu kişi/firma", text: $localIssue.responsibility)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Deadline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Termin Tarihi")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        DatePicker(
                            "",
                            selection: Binding(
                                get: { localIssue.deadline ?? Date() },
                                set: { localIssue.deadline = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }

                    // Approved
                    Toggle("Onaylandı", isOn: $localIssue.approved)
                }

                // Save button
                Button {
                    onUpdate(localIssue)
                } label: {
                    Label("Kaydet", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    let form = FilledForm(templateId: "test")

    return IssueLogSectionView(form: form, maxItems: 5)
        .padding()
}
