//
//  AddDependencySheet.swift
//  TestFormApp
//
//  Sheet for adding a new dependency
//

import SwiftUI

struct AddDependencySheet: View {
    @Environment(\.dismiss) private var dismiss

    let availableItems: [ChecklistTemplateItem]
    let currentItemNumber: Int
    let onAdd: (ItemDependency) -> Void

    @State private var selectedType: DependencyType = .requiresYes
    @State private var selectedTargets: Set<Int> = []
    @State private var message: String = ""
    @State private var severity: DependencySeverity = .error

    var body: some View {
        NavigationStack {
            Form {
                // Dependency type
                Section {
                    Picker("Bağımlılık Tipi", selection: $selectedType) {
                        ForEach(DependencyType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    // Type description
                    Text(typeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Tip")
                }

                // Target items
                Section {
                    if availableTargetItems.isEmpty {
                        Text("Başka madde bulunmamaktadır")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableTargetItems) { item in
                            Toggle(isOn: Binding(
                                get: { selectedTargets.contains(item.number) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedTargets.insert(item.number)
                                    } else {
                                        selectedTargets.remove(item.number)
                                    }
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Madde \(item.number)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Hedef Maddeler")
                } footer: {
                    Text("Bu bağımlılık için kontrol edilecek maddeleri seçin")
                }

                // Message
                Section {
                    TextField("Uyarı mesajı", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Mesaj")
                } footer: {
                    Text("Bağımlılık ihlal edildiğinde gösterilecek mesaj")
                }

                // Severity
                Section {
                    Picker("Önem Derecesi", selection: $severity) {
                        Label("Hata (Engelle)", systemImage: "xmark.circle.fill")
                            .tag(DependencySeverity.error)

                        Label("Uyarı", systemImage: "exclamationmark.triangle.fill")
                            .tag(DependencySeverity.warning)

                        Label("Bilgi", systemImage: "info.circle.fill")
                            .tag(DependencySeverity.info)
                    }

                    Text(severityDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Önem Derecesi")
                }
            }
            .navigationTitle("Yeni Bağımlılık")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Ekle") {
                        addDependency()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var availableTargetItems: [ChecklistTemplateItem] {
        availableItems.filter { $0.number != currentItemNumber }
    }

    private var isValid: Bool {
        !selectedTargets.isEmpty && !message.isEmpty
    }

    private var typeDescription: String {
        switch selectedType {
        case .requiresYes:
            return "Hedef maddeler EVET durumunda olmalıdır"
        case .requiresNo:
            return "Hedef maddeler HAYIR durumunda olmalıdır"
        case .requiresNotNA:
            return "Hedef maddeler N/A durumunda olmamalıdır"
        case .requiresAnyYes:
            return "Hedef maddelerden en az biri EVET olmalıdır"
        case .requiresAllYes:
            return "Hedef maddelerin tümü EVET olmalıdır"
        case .blockedIfYes:
            return "Hedef maddeler EVET ise bu madde engellenecektir"
        case .blockedIfNo:
            return "Hedef maddeler HAYIR ise bu madde engellenecektir"
        }
    }

    private var severityDescription: String {
        switch severity {
        case .error:
            return "Kullanıcı bağımlılık sağlanmadan devam edemez"
        case .warning:
            return "Kullanıcı uyarılır ancak devam edebilir"
        case .info:
            return "Sadece bilgilendirme amaçlıdır"
        }
    }

    private func addDependency() {
        let dependency = ItemDependency(
            type: selectedType,
            targetItemNumbers: Array(selectedTargets).sorted(),
            message: message,
            severity: severity
        )
        onAdd(dependency)
        dismiss()
    }
}

#Preview {
    let items = [
        ChecklistTemplateItem(number: 1, description: "İlk madde"),
        ChecklistTemplateItem(number: 2, description: "İkinci madde"),
        ChecklistTemplateItem(number: 3, description: "Üçüncü madde")
    ]

    return AddDependencySheet(
        availableItems: items,
        currentItemNumber: 2,
        onAdd: { _ in }
    )
}
