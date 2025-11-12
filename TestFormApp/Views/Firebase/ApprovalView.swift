//
//  ApprovalView.swift
//  TestFormApp
//
//  View for approving and uploading test documents to Firebase
//

import SwiftUI

struct ApprovalView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var dataManager: FilledFormDataManager
    @Environment(\.dismiss) private var dismiss

    let form: FilledForm
    let template: FormTemplate
    let pdfData: Data

    @State private var showingAuthSheet = false
    @State private var isUploading = false
    @State private var uploadSuccess = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?

    private var completionPercentage: Double {
        form.completionPercentage(template: template)
    }

    private var canApprove: Bool {
        completionPercentage >= 100
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Warning/Info Section
                    if !canApprove {
                        warningSection
                    } else {
                        readySection
                    }

                    // Document Info
                    documentInfoSection

                    // Approval Info
                    if firebaseManager.isAuthenticated {
                        approvalInfoSection
                    }

                    // Action Button
                    if firebaseManager.isAuthenticated {
                        approveButton
                    } else {
                        signInButton
                    }
                }
                .padding()
            }
            .navigationTitle("Döküman Onayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAuthSheet) {
                AuthenticationView()
            }
            .alert("Başarılı", isPresented: $showingSuccessAlert) {
                Button("Tamam", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Döküman başarıyla onaylandı ve yüklendi. Artık tüm kullanıcılar bu dökümana erişebilir.")
            }
            .alert("Hata", isPresented: .constant(errorMessage != nil)) {
                Button("Tamam", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }

    private var warningSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Form Tamamlanmamış")
                .font(.title3)
                .fontWeight(.bold)

            Text("Form %\(Int(completionPercentage)) tamamlanmış. Onaylamak için tüm alanların doldurulması gerekmektedir.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ProgressBar(percentage: completionPercentage)
                .frame(height: 8)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var readySection: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)

            Text("Onaya Hazır")
                .font(.title3)
                .fontWeight(.bold)

            Text("Form tamamlandı ve onaylanmaya hazır. Onayladıktan sonra döküman tüm kullanıcılarla paylaşılacaktır.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var documentInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Döküman Bilgileri")
                .font(.headline)

            VStack(spacing: 12) {
                InfoRow(label: "Form", value: template.title)
                InfoRow(label: "Kategori", value: "\(template.category) - Seviye \(template.level)")

                if let equipmentName = form.equipmentInfo["equipment_name"], !equipmentName.isEmpty {
                    InfoRow(label: "Ekipman", value: equipmentName)
                }

                if let equipmentNumber = form.equipmentInfo["equipment_number"], !equipmentNumber.isEmpty {
                    InfoRow(label: "Ekipman No", value: equipmentNumber)
                }

                InfoRow(label: "Oluşturulma", value: form.createdDate.formatted(date: .long, time: .shortened))
                InfoRow(label: "Tamamlanma", value: String(format: "%.0f%%", completionPercentage))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var approvalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Onay Bilgileri")
                .font(.headline)

            VStack(spacing: 12) {
                if let user = firebaseManager.currentUser {
                    InfoRow(
                        label: "Onaylayan",
                        value: user.displayName ?? user.email ?? "Anonim"
                    )

                    if let email = user.email {
                        InfoRow(label: "E-posta", value: email)
                    }
                }

                InfoRow(label: "Onay Tarihi", value: Date().formatted(date: .long, time: .shortened))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var approveButton: some View {
        Button {
            Task {
                await approveAndUpload()
            }
        } label: {
            HStack {
                if isUploading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                }

                Text(isUploading ? "Yükleniyor..." : "Onayla ve Yükle")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canApprove && !isUploading ? Color.green : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canApprove || isUploading)
    }

    private var signInButton: some View {
        Button {
            showingAuthSheet = true
        } label: {
            HStack {
                Image(systemName: "person.circle")

                Text("Onaylamak İçin Giriş Yap")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func approveAndUpload() async {
        guard canApprove else { return }

        isUploading = true
        errorMessage = nil

        do {
            // Upload to Firebase
            let downloadURL = try await firebaseManager.uploadPDF(
                pdfData: pdfData,
                form: form,
                template: template
            )

            // Update local form
            form.isApproved = true
            form.approvedDate = Date()
            form.approvedBy = firebaseManager.currentUser?.displayName ?? firebaseManager.currentUser?.email
            form.firebaseDocumentURL = downloadURL

            // Save to local database
            dataManager.update(form)

            isUploading = false
            uploadSuccess = true
            showingSuccessAlert = true
        } catch {
            isUploading = false
            errorMessage = error.localizedDescription
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    let template = FormTemplate(
        formId: "test",
        category: "UPS",
        level: "L2",
        title: "UPS Test Form",
        sections: []
    )
    let form = FilledForm(templateId: "test")
    let pdfData = Data()

    return ApprovalView(form: form, template: template, pdfData: pdfData)
        .environmentObject(FirebaseManager.shared)
        .environmentObject(FilledFormDataManager())
}
