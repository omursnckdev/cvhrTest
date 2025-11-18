//
//  FormDetailView.swift
//  TestFormApp
//
//  Detail view for form approval with PDF preview
//

import SwiftUI
import PDFKit

struct FormDetailView: View {
    @EnvironmentObject var formDataManager: FilledFormDataManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss

    let form: FilledForm
    let template: FormTemplate
    let role: UserRole

    @State private var showPDFPreview = false
    @State private var pdfData: Data?
    @State private var showApprovalConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Form header
                VStack(alignment: .leading, spacing: 12) {
                    Text(template.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Label(template.category, systemImage: "folder")
                        Spacer()
                        Label(template.level, systemImage: "chart.bar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Divider()

                    // Creator info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Oluşturan:")
                                .fontWeight(.semibold)
                            Text(form.createdByUsername)
                        }

                        HStack {
                            Text("Oluşturma Tarihi:")
                                .fontWeight(.semibold)
                            Text(form.createdDate.formatted(date: .long, time: .shortened))
                        }
                    }
                    .font(.subheadline)

                    // Approval status
                    HStack {
                        Text("Durum:")
                            .fontWeight(.semibold)
                        Text(form.approvalStatus.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(8)
                    }
                    .font(.subheadline)

                    // Approval history
                    if let musavirBy = form.musavirApprovedBy,
                       let musavirDate = form.musavirApprovedDate {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Müşavir Onayı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(musavirBy) - \(musavirDate.formatted(date: .abbreviated, time: .shortened))")
                            }
                            .font(.subheadline)
                        }
                    }

                    if let isverenBy = form.isverenApprovedBy,
                       let isverenDate = form.isverenApprovedDate {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("İşVeren Onayı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("\(isverenBy) - \(isverenDate.formatted(date: .abbreviated, time: .shortened))")
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)

                // PDF Preview button
                Button {
                    generatePDF()
                    showPDFPreview = true
                } label: {
                    Label("PDF Önizleme", systemImage: "doc.text.magnifyingglass")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Approval button (only for appropriate roles)
                if canApprove {
                    Button {
                        showApprovalConfirmation = true
                    } label: {
                        Label("Onayla", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPDFPreview) {
            if let pdfData = pdfData {
                PDFPreviewView(pdfData: pdfData)
            }
        }
        .alert("Onay", isPresented: $showApprovalConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Onayla", role: .destructive) {
                approveForm()
            }
        } message: {
            Text("Bu formu onaylamak istediğinizden emin misiniz?")
        }
    }

    private var canApprove: Bool {
        switch role {
        case .musavir:
            return form.approvalStatus == .pendingMusavir
        case .isveren:
            return form.approvalStatus == .pendingIsveren
        case .muteahhit:
            return false
        }
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

    private func generatePDF() {
        let generator = PDFGenerator()
        pdfData = generator.generatePDF(from: form, template: template)
    }

    private func approveForm() {
        guard let username = userManager.currentUser?.username else { return }

        switch role {
        case .musavir:
            formDataManager.approveAsMusavir(form, approvedBy: username)
        case .isveren:
            formDataManager.approveAsIsveren(form, approvedBy: username)
        case .muteahhit:
            break
        }

        dismiss()
    }
}

struct PDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let pdfData: Data

    var body: some View {
        NavigationView {
            Group {
                if let pdfDocument = PDFDocument(data: pdfData) {
                    PDFKitView(pdfDocument: pdfDocument)
                } else {
                    Text("PDF yüklenemedi")
                }
            }
            .navigationTitle("PDF Önizleme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let pdfDocument = PDFDocument(data: pdfData) {
                        ShareLink(item: pdfDocument, preview: SharePreview("Test Form"))
                    }
                }
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

#Preview {
    NavigationView {
        FormDetailView(
            form: FilledForm(templateId: "test", createdByUsername: "testuser"),
            template: FormTemplate(
                formId: "test",
                category: "Trafo",
                level: "L1",
                title: "Test Form",
                sections: []
            ),
            role: .musavir
        )
        .environmentObject(FilledFormDataManager())
        .environmentObject(UserManager(modelContext: ModelContext(try! ModelContainer(for: User.self))))
    }
}
