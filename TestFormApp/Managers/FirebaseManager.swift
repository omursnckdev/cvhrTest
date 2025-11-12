//
//  FirebaseManager.swift
//  TestFormApp
//
//  Manages Firebase authentication, storage, and Firestore operations
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

/// Document metadata stored in Firestore
struct ApprovedDocument: Codable, Identifiable {
    let id: String
    let templateId: String
    let templateTitle: String
    let category: String
    let level: String
    let equipmentName: String
    let equipmentNumber: String
    let testDate: Date
    let approvedBy: String
    let approvedByEmail: String
    let approvedDate: Date
    let pdfStoragePath: String
    let pdfDownloadURL: String
    let completionPercentage: Double

    enum CodingKeys: String, CodingKey {
        case id, templateId, templateTitle, category, level
        case equipmentName, equipmentNumber, testDate
        case approvedBy, approvedByEmail, approvedDate
        case pdfStoragePath, pdfDownloadURL, completionPercentage
    }
}

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var approvedDocuments: [ApprovedDocument] = []

    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()

    private init() {
        // Configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Check authentication state
        checkAuthenticationState()
    }

    // MARK: - Authentication

    func checkAuthenticationState() {
        if let user = auth.currentUser {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    /// Sign in anonymously (for demo purposes)
    func signInAnonymously() async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await auth.signInAnonymously()
            self.currentUser = result.user
            self.isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = "Giriş hatası: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            self.currentUser = result.user
            self.isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = "Giriş hatası: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Sign up with email and password
    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await auth.createUser(withEmail: email, password: password)

            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()

            self.currentUser = result.user
            self.isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = "Kayıt hatası: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Sign out
    func signOut() throws {
        try auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Storage Operations

    /// Upload PDF document to Firebase Storage
    func uploadPDF(
        pdfData: Data,
        form: FilledForm,
        template: FormTemplate
    ) async throws -> String {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Kullanıcı oturumu açmamış"
            ])
        }

        isLoading = true
        errorMessage = nil

        // Create unique filename
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(template.category)_\(template.level)_\(form.id.uuidString)_\(Int(timestamp)).pdf"
        let storagePath = "approved_documents/\(filename)"

        // Create storage reference
        let storageRef = storage.reference().child(storagePath)

        do {
            // Upload PDF
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"

            let _ = try await storageRef.putDataAsync(pdfData, metadata: metadata)

            // Get download URL
            let downloadURL = try await storageRef.downloadURL()

            // Create document metadata
            let document = ApprovedDocument(
                id: form.id.uuidString,
                templateId: template.formId,
                templateTitle: template.title,
                category: template.category,
                level: template.level,
                equipmentName: form.equipmentInfo["equipment_name"] ?? "",
                equipmentNumber: form.equipmentInfo["equipment_number"] ?? "",
                testDate: form.createdDate,
                approvedBy: user.displayName ?? user.email ?? "Anonim",
                approvedByEmail: user.email ?? "",
                approvedDate: Date(),
                pdfStoragePath: storagePath,
                pdfDownloadURL: downloadURL.absoluteString,
                completionPercentage: form.completionPercentage(template: template)
            )

            // Save metadata to Firestore
            try await saveDocumentMetadata(document)

            isLoading = false
            return downloadURL.absoluteString
        } catch {
            errorMessage = "Yükleme hatası: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Delete document from storage
    func deleteDocument(_ document: ApprovedDocument) async throws {
        guard currentUser != nil else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Kullanıcı oturumu açmamış"
            ])
        }

        isLoading = true
        errorMessage = nil

        do {
            // Delete from storage
            let storageRef = storage.reference().child(document.pdfStoragePath)
            try await storageRef.delete()

            // Delete from Firestore
            try await firestore.collection("approved_documents").document(document.id).delete()

            // Remove from local array
            approvedDocuments.removeAll { $0.id == document.id }

            isLoading = false
        } catch {
            errorMessage = "Silme hatası: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    // MARK: - Firestore Operations

    /// Save document metadata to Firestore
    private func saveDocumentMetadata(_ document: ApprovedDocument) async throws {
        let docRef = firestore.collection("approved_documents").document(document.id)

        let data: [String: Any] = [
            "id": document.id,
            "templateId": document.templateId,
            "templateTitle": document.templateTitle,
            "category": document.category,
            "level": document.level,
            "equipmentName": document.equipmentName,
            "equipmentNumber": document.equipmentNumber,
            "testDate": Timestamp(date: document.testDate),
            "approvedBy": document.approvedBy,
            "approvedByEmail": document.approvedByEmail,
            "approvedDate": Timestamp(date: document.approvedDate),
            "pdfStoragePath": document.pdfStoragePath,
            "pdfDownloadURL": document.pdfDownloadURL,
            "completionPercentage": document.completionPercentage
        ]

        try await docRef.setData(data)
    }

    /// Fetch all approved documents
    func fetchApprovedDocuments() async throws {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await firestore.collection("approved_documents")
                .order(by: "approvedDate", descending: true)
                .getDocuments()

            var documents: [ApprovedDocument] = []

            for document in snapshot.documents {
                let data = document.data()

                guard let id = data["id"] as? String,
                      let templateId = data["templateId"] as? String,
                      let templateTitle = data["templateTitle"] as? String,
                      let category = data["category"] as? String,
                      let level = data["level"] as? String,
                      let equipmentName = data["equipmentName"] as? String,
                      let equipmentNumber = data["equipmentNumber"] as? String,
                      let testDate = (data["testDate"] as? Timestamp)?.dateValue(),
                      let approvedBy = data["approvedBy"] as? String,
                      let approvedByEmail = data["approvedByEmail"] as? String,
                      let approvedDate = (data["approvedDate"] as? Timestamp)?.dateValue(),
                      let pdfStoragePath = data["pdfStoragePath"] as? String,
                      let pdfDownloadURL = data["pdfDownloadURL"] as? String,
                      let completionPercentage = data["completionPercentage"] as? Double else {
                    continue
                }

                let doc = ApprovedDocument(
                    id: id,
                    templateId: templateId,
                    templateTitle: templateTitle,
                    category: category,
                    level: level,
                    equipmentName: equipmentName,
                    equipmentNumber: equipmentNumber,
                    testDate: testDate,
                    approvedBy: approvedBy,
                    approvedByEmail: approvedByEmail,
                    approvedDate: approvedDate,
                    pdfStoragePath: pdfStoragePath,
                    pdfDownloadURL: pdfDownloadURL,
                    completionPercentage: completionPercentage
                )

                documents.append(doc)
            }

            self.approvedDocuments = documents
            isLoading = false
        } catch {
            errorMessage = "Dökümanlar yüklenemedi: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Search documents by category
    func searchDocuments(category: String? = nil, level: String? = nil) async throws -> [ApprovedDocument] {
        var query: Query = firestore.collection("approved_documents")
            .order(by: "approvedDate", descending: true)

        if let category = category {
            query = query.whereField("category", isEqualTo: category)
        }

        if let level = level {
            query = query.whereField("level", isEqualTo: level)
        }

        let snapshot = try await query.getDocuments()

        var documents: [ApprovedDocument] = []

        for document in snapshot.documents {
            let data = document.data()

            guard let id = data["id"] as? String,
                  let templateId = data["templateId"] as? String,
                  let templateTitle = data["templateTitle"] as? String,
                  let category = data["category"] as? String,
                  let level = data["level"] as? String,
                  let equipmentName = data["equipmentName"] as? String,
                  let equipmentNumber = data["equipmentNumber"] as? String,
                  let testDate = (data["testDate"] as? Timestamp)?.dateValue(),
                  let approvedBy = data["approvedBy"] as? String,
                  let approvedByEmail = data["approvedByEmail"] as? String,
                  let approvedDate = (data["approvedDate"] as? Timestamp)?.dateValue(),
                  let pdfStoragePath = data["pdfStoragePath"] as? String,
                  let pdfDownloadURL = data["pdfDownloadURL"] as? String,
                  let completionPercentage = data["completionPercentage"] as? Double else {
                continue
            }

            let doc = ApprovedDocument(
                id: id,
                templateId: templateId,
                templateTitle: templateTitle,
                category: category,
                level: level,
                equipmentName: equipmentName,
                equipmentNumber: equipmentNumber,
                testDate: testDate,
                approvedBy: approvedBy,
                approvedByEmail: approvedByEmail,
                approvedDate: approvedDate,
                pdfStoragePath: pdfStoragePath,
                pdfDownloadURL: pdfDownloadURL,
                completionPercentage: completionPercentage
            )

            documents.append(doc)
        }

        return documents
    }

    /// Download PDF from URL
    func downloadPDF(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "FirebaseManager", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Geçersiz URL"
            ])
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
