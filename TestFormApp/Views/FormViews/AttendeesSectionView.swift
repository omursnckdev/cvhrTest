//
//  AttendeesSectionView.swift
//  TestFormApp
//
//  Section for managing attendees and signatures
//

import SwiftUI
import PencilKit

struct AttendeesSectionView: View {
    @ObservedObject var form: FilledForm
    let companies: [String]

    @State private var showingSignature: Attendee?

    var body: some View {
        VStack(spacing: 16) {
            ForEach(form.attendees) { attendee in
                AttendeeRow(
                    attendee: attendee,
                    onUpdate: { updatedAttendee in
                        updateAttendee(updatedAttendee)
                    },
                    onEditSignature: {
                        showingSignature = attendee
                    }
                )
            }
        }
        .sheet(item: $showingSignature) { attendee in
            SignatureView(attendee: attendee) { updatedAttendee in
                updateAttendee(updatedAttendee)
                showingSignature = nil
            }
        }
    }

    private func updateAttendee(_ updatedAttendee: Attendee) {
        var attendees = form.attendees
        if let index = attendees.firstIndex(where: { $0.id == updatedAttendee.id }) {
            attendees[index] = updatedAttendee
            form.attendees = attendees
        }
    }
}

struct AttendeeRow: View {
    let attendee: Attendee
    let onUpdate: (Attendee) -> Void
    let onEditSignature: () -> Void

    @State private var localAttendee: Attendee

    init(
        attendee: Attendee,
        onUpdate: @escaping (Attendee) -> Void,
        onEditSignature: @escaping () -> Void
    ) {
        self.attendee = attendee
        self.onUpdate = onUpdate
        self.onEditSignature = onEditSignature
        _localAttendee = State(initialValue: attendee)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Company header
            Text(localAttendee.company)
                .font(.headline)
                .foregroundStyle(.blue)

            // Name
            VStack(alignment: .leading, spacing: 4) {
                Text("İsim")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Ad Soyad", text: $localAttendee.name)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: localAttendee.name) { _, _ in
                        onUpdate(localAttendee)
                    }
            }

            // Date
            VStack(alignment: .leading, spacing: 4) {
                Text("Tarih")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                DatePicker(
                    "",
                    selection: Binding(
                        get: { localAttendee.date ?? Date() },
                        set: { newDate in
                            localAttendee.date = newDate
                            onUpdate(localAttendee)
                        }
                    ),
                    displayedComponents: .date
                )
                .labelsHidden()
            }

            // Signature
            VStack(alignment: .leading, spacing: 4) {
                Text("İmza")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    onEditSignature()
                } label: {
                    if let signatureData = localAttendee.signatureData,
                       let uiImage = UIImage(data: signatureData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Label("İmza Ekle", systemImage: "signature")
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SignatureView: View {
    let attendee: Attendee
    let onSave: (Attendee) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var canvas = PKCanvasView()
    @State private var hasDrawing = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("İmza ekleyin")
                    .font(.headline)
                    .padding()

                SignatureCanvasView(
                    canvasView: $canvas,
                    hasDrawing: $hasDrawing
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
            .navigationTitle("\(attendee.company) İmzası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Temizle") {
                        canvas.drawing = PKDrawing()
                        hasDrawing = false
                    }
                    .disabled(!hasDrawing)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Kaydet") {
                        saveSignature()
                    }
                    .fontWeight(.bold)
                    .disabled(!hasDrawing)
                }
            }
        }
    }

    private func saveSignature() {
        let image = canvas.drawing.image(from: canvas.bounds, scale: 1.0)
        var updatedAttendee = attendee
        updatedAttendee.signatureData = image.pngData()
        onSave(updatedAttendee)
    }
}

struct SignatureCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var hasDrawing: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(hasDrawing: $hasDrawing)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var hasDrawing: Bool

        init(hasDrawing: Binding<Bool>) {
            _hasDrawing = hasDrawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            hasDrawing = !canvasView.drawing.bounds.isEmpty
        }
    }
}

#Preview {
    let form = FilledForm(templateId: "test")

    return AttendeesSectionView(
        form: form,
        companies: ["CEVAHİR YAPI", "HILL INTERNATIONAL", "TURKCELL"]
    )
    .padding()
}
