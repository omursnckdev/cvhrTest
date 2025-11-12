//
//  DynamicFormView.swift
//  TestFormApp
//
//  Main dynamic form view that renders sections based on template
//

import SwiftUI

struct DynamicFormView: View {
    @EnvironmentObject var dataManager: FilledFormDataManager
    @EnvironmentObject var firebaseManager: FirebaseManager

    let form: FilledForm
    let template: FormTemplate
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var showingExportSheet = false
    @State private var showingApprovalView = false
    @State private var pdfData: Data?

    private var completionPercentage: Double {
        form.completionPercentage(template: template)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Progress header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tamamlanma")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(String(format: "%.0f%%", completionPercentage))
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Spacer()

                        if completionPercentage >= 100 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                        }
                    }

                    ProgressBar(percentage: completionPercentage)
                        .frame(height: 8)
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                // Form sections
                LazyVStack(spacing: 16) {
                    ForEach(template.sections) { section in
                        sectionView(for: section)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isNew {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        saveForm()
                    } label: {
                        Label("Kaydet", systemImage: "square.and.arrow.down")
                    }

                    Button {
                        exportToPDF()
                    } label: {
                        Label("PDF Oluştur", systemImage: "doc.text")
                    }

                    Divider()

                    if form.isApproved {
                        Label("Onaylandı", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            approveDocument()
                        } label: {
                            Label("Onayla ve Yükle", systemImage: "checkmark.seal.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Form Kaydedildi", isPresented: $showingSaveAlert) {
            Button("Tamam", role: .cancel) {
                if isNew {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let pdfData = pdfData {
                PDFPreviewView(pdfData: pdfData, filename: "\(template.title)_\(Date().formatted(date: .numeric, time: .omitted)).pdf")
            }
        }
        .sheet(isPresented: $showingApprovalView) {
            if let pdfData = pdfData {
                ApprovalView(form: form, template: template, pdfData: pdfData)
            }
        }
    }

    @ViewBuilder
    private func sectionView(for section: FormSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title3)
                .fontWeight(.bold)

            switch section.type {
            case .info:
                if let fields = section.fields {
                    InfoSectionView(form: form, fields: fields)
                }

            case .checklist:
                if let items = section.items {
                    ChecklistSectionView(
                        form: form,
                        sectionId: section.id,
                        items: items
                    )
                }

            case .issueLog:
                IssueLogSectionView(form: form, maxItems: section.maxItems ?? 10)

            case .attendees:
                if let companies = section.companies {
                    AttendeesSectionView(form: form, companies: companies)
                }

            case .notes:
                NotesSectionView(form: form)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func saveForm() {
        dataManager.save(form)
        showingSaveAlert = true
    }

    private func exportToPDF() {
        let generator = PDFGenerator()
        if let data = generator.generatePDF(from: form, template: template) {
            pdfData = data
            showingExportSheet = true
        }
    }

    private func approveDocument() {
        // First save the form
        dataManager.save(form)

        // Generate PDF
        let generator = PDFGenerator()
        if let data = generator.generatePDF(from: form, template: template) {
            pdfData = data
            showingApprovalView = true
        }
    }
}

// PDF Preview View
struct PDFPreviewView: View {
    let pdfData: Data
    let filename: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PDFKitView(data: pdfData)
                .navigationTitle("PDF Önizleme")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Kapat") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: PDFFile(data: pdfData, filename: filename)) {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
}

// Helper for ShareLink
struct PDFFile: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { pdf in
            pdf.data
        }
    }
}

// PDFKit View Wrapper
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // No update needed
    }
}

#Preview {
    let template = FormTemplate(
        formId: "test",
        category: "UPS",
        level: "L2",
        title: "Test Form",
        sections: []
    )
    let form = FilledForm(templateId: "test")

    return NavigationStack {
        DynamicFormView(form: form, template: template)
            .environmentObject(FilledFormDataManager())
    }
}
