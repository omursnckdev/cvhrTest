//
//  DynamicFormView.swift
//  TestFormApp
//
//  Main dynamic form view that renders sections based on template
//

import SwiftUI

struct DynamicFormView: View {
    @EnvironmentObject var dataManager: FilledFormDataManager
    @EnvironmentObject var userManager: UserManager

    let form: FilledForm
    let template: FormTemplate
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var showingSubmitConfirmation = false
    @State private var showingExportSheet = false
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
                    // Save as draft (Müteahhit only)
                    if userManager.currentUser?.role == .muteahhit {
                        Button {
                            saveForm()
                        } label: {
                            Label("Kaydet", systemImage: "square.and.arrow.down")
                        }

                        // Submit for approval button
                        if !isNew && form.approvalStatus == .draft {
                            Button {
                                showingSubmitConfirmation = true
                            } label: {
                                Label("Onaya Gönder", systemImage: "paperplane")
                            }
                        }
                    }

                    Button {
                        exportToPDF()
                    } label: {
                        Label("PDF Oluştur", systemImage: "doc.text")
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
        .alert("Onaya Gönder", isPresented: $showingSubmitConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Gönder", role: .destructive) {
                submitForApproval()
            }
        } message: {
            Text("Formu onaya göndermek istediğinizden emin misiniz? Gönderildikten sonra Müşavir tarafından incelenecektir.")
        }
        .sheet(isPresented: $showingExportSheet) {
            if let pdfData = pdfData {
                PDFPreviewView(pdfData: pdfData, filename: "\(template.title)_\(Date().formatted(date: .numeric, time: .omitted)).pdf")
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
        // Set creator username if this is a new form
        if isNew, let username = userManager.currentUser?.username {
            form.createdByUsername = username
        }
        dataManager.save(form)
        showingSaveAlert = true
    }

    private func submitForApproval() {
        dataManager.submitForApproval(form)
        dismiss()
    }

    private func exportToPDF() {
        let generator = PDFGenerator()
        if let data = generator.generatePDF(from: form, template: template) {
            pdfData = data
            showingExportSheet = true
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
