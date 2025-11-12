//
//  InfoSectionView.swift
//  TestFormApp
//
//  Form section for equipment information fields
//

import SwiftUI

struct InfoSectionView: View {
    @ObservedObject var form: FilledForm
    let fields: [FormField]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(fields) { field in
                fieldView(for: field)
            }
        }
    }

    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(field.label)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if field.isRequired {
                    Text("*")
                        .foregroundStyle(.red)
                }
            }

            switch field.type {
            case .text, .number:
                TextField(field.label, text: binding(for: field.id))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(field.type == .number ? .decimalPad : .default)

            case .date:
                DatePicker(
                    "",
                    selection: dateBinding(for: field.id),
                    displayedComponents: .date
                )
                .labelsHidden()

            case .picker:
                if let options = field.options {
                    Picker("", selection: binding(for: field.id)) {
                        Text("Seçiniz").tag("")
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    private func binding(for fieldId: String) -> Binding<String> {
        Binding(
            get: {
                form.equipmentInfo[fieldId] ?? ""
            },
            set: { newValue in
                var info = form.equipmentInfo
                info[fieldId] = newValue
                form.equipmentInfo = info
            }
        )
    }

    private func dateBinding(for fieldId: String) -> Binding<Date> {
        Binding(
            get: {
                if let dateString = form.equipmentInfo[fieldId],
                   let date = ISO8601DateFormatter().date(from: dateString) {
                    return date
                }
                return Date()
            },
            set: { newValue in
                var info = form.equipmentInfo
                let formatter = ISO8601DateFormatter()
                info[fieldId] = formatter.string(from: newValue)
                form.equipmentInfo = info
            }
        )
    }
}

#Preview {
    let form = FilledForm(templateId: "test")

    let fields = [
        FormField(id: "equipment_name", label: "Ekipman Adı", type: .text, defaultValue: nil, required: true, options: nil),
        FormField(id: "serial_number", label: "Seri No", type: .text, defaultValue: nil, required: false, options: nil),
        FormField(id: "power_capacity", label: "Güç - Kapasite", type: .number, defaultValue: nil, required: false, options: nil),
        FormField(id: "test_date", label: "Test Tarihi", type: .date, defaultValue: nil, required: true, options: nil)
    ]

    return InfoSectionView(form: form, fields: fields)
        .padding()
}
