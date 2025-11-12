//
//  SharedDocumentsView.swift
//  TestFormApp
//
//  View to display all approved documents from Firebase
//

import SwiftUI
import PDFKit

struct SharedDocumentsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedDocument: ApprovedDocument?
    @State private var showingPDF = false
    @State private var showingAuthSheet = false

    private var filteredDocuments: [ApprovedDocument] {
        var documents = firebaseManager.approvedDocuments

        if !searchText.isEmpty {
            documents = documents.filter {
                $0.templateTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.equipmentName.localizedCaseInsensitiveContains(searchText) ||
                $0.equipmentNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.approvedBy.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let category = selectedCategory {
            documents = documents.filter { $0.category == category }
        }

        return documents
    }

    private var categories: [String] {
        let allCategories = Set(firebaseManager.approvedDocuments.map { $0.category })
        return Array(allCategories).sorted()
    }

    var body: some View {
        NavigationStack {
            Group {
                if !firebaseManager.isAuthenticated {
                    notAuthenticatedView
                } else if firebaseManager.isLoading {
                    ProgressView("Yükleniyor...")
                } else if firebaseManager.approvedDocuments.isEmpty {
                    emptyStateView
                } else {
                    documentsList
                }
            }
            .navigationTitle("Onaylı Dökümanlar")
            .searchable(text: $searchText, prompt: "Ara...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if firebaseManager.isAuthenticated {
                        Button {
                            Task {
                                await refreshDocuments()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(firebaseManager.isLoading)
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    if !firebaseManager.isAuthenticated {
                        Button {
                            showingAuthSheet = true
                        } label: {
                            Label("Giriş Yap", systemImage: "person.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAuthSheet) {
                AuthenticationView()
            }
            .sheet(isPresented: $showingPDF) {
                if let document = selectedDocument {
                    PDFViewerSheet(document: document)
                }
            }
            .task {
                if firebaseManager.isAuthenticated && firebaseManager.approvedDocuments.isEmpty {
                    await refreshDocuments()
                }
            }
        }
    }

    private var notAuthenticatedView: some View {
        ContentUnavailableView(
            "Giriş Gerekli",
            systemImage: "person.crop.circle.badge.exclamationmark",
            description: Text("Onaylı dökümanları görmek için giriş yapmalısınız")
        )
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "Döküman Bulunamadı",
            systemImage: "doc.text.magnifyingglass",
            description: Text("Henüz onaylanmış döküman bulunmamaktadır")
        )
    }

    private var documentsList: some View {
        List {
            // Category filter
            if !categories.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "Tümü",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(categories, id: \.self) { category in
                                FilterChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // Documents
            Section {
                ForEach(filteredDocuments) { document in
                    ApprovedDocumentRow(document: document)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDocument = document
                            showingPDF = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await deleteDocument(document)
                                }
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }

                            ShareLink(item: URL(string: document.pdfDownloadURL)!) {
                                Label("Paylaş", systemImage: "square.and.arrow.up")
                            }
                            .tint(.blue)
                        }
                }
            } header: {
                if !filteredDocuments.isEmpty {
                    Text("\(filteredDocuments.count) döküman")
                }
            }
        }
    }

    private func refreshDocuments() async {
        do {
            try await firebaseManager.fetchApprovedDocuments()
        } catch {
            // Error handled in FirebaseManager
        }
    }

    private func deleteDocument(_ document: ApprovedDocument) async {
        do {
            try await firebaseManager.deleteDocument(document)
        } catch {
            // Error handled in FirebaseManager
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct ApprovedDocumentRow: View {
    let document: ApprovedDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.templateTitle)
                        .font(.headline)

                    HStack {
                        Text(document.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())

                        Text("Seviye \(document.level)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }

            // Equipment info
            if !document.equipmentName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label(document.equipmentName, systemImage: "gearshape.fill")
                        .font(.subheadline)

                    if !document.equipmentNumber.isEmpty {
                        Text("No: \(document.equipmentNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Progress
            HStack {
                Text("Tamamlanma")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(String(format: "%.0f%%", document.completionPercentage))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            ProgressBar(percentage: document.completionPercentage)
                .frame(height: 6)

            Divider()

            // Approval info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)

                    Text(document.approvedBy)
                        .font(.caption)

                    Spacer()

                    Text(document.approvedDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct PDFViewerSheet: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) private var dismiss

    let document: ApprovedDocument

    @State private var pdfData: Data?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("PDF yükleniyor...")
                } else if let error = errorMessage {
                    ContentUnavailableView(
                        "Hata",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if let pdfData = pdfData {
                    PDFKitView(data: pdfData)
                }
            }
            .navigationTitle(document.templateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if let pdfData = pdfData {
                        ShareLink(item: PDFFile(data: pdfData, filename: "\(document.templateTitle).pdf")) {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                await loadPDF()
            }
        }
    }

    private func loadPDF() async {
        isLoading = true
        errorMessage = nil

        do {
            pdfData = try await firebaseManager.downloadPDF(from: document.pdfDownloadURL)
            isLoading = false
        } catch {
            errorMessage = "PDF yüklenemedi: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

#Preview {
    SharedDocumentsView()
        .environmentObject(FirebaseManager.shared)
}
