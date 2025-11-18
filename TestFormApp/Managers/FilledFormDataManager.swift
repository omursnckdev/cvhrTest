//
//  FilledFormDataManager.swift
//  TestFormApp
//
//  Manages persistence of filled forms using SwiftData
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class FilledFormDataManager: ObservableObject {
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?

    @Published var filledForms: [FilledForm] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(modelContainer: ModelContainer? = nil) {
        self.modelContainer = modelContainer
        if let container = modelContainer {
            self.modelContext = ModelContext(container)
            loadForms()
        }
    }

    /// Setup the model container
    func setup(container: ModelContainer) {
        self.modelContainer = container
        self.modelContext = ModelContext(container)
        loadForms()
    }

    /// Load all forms from SwiftData
    func loadForms() {
        guard let context = modelContext else { return }

        isLoading = true
        do {
            let descriptor = FetchDescriptor<FilledForm>(
                sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
            )
            filledForms = try context.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Form yükleme hatası: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Save a new or existing form
    func save(_ form: FilledForm) {
        guard let context = modelContext else { return }

        form.lastModified = Date()

        // Insert if new
        if context.model(for: form.id) == nil {
            context.insert(form)
        }

        do {
            try context.save()
            loadForms()
        } catch {
            errorMessage = "Kaydetme hatası: \(error.localizedDescription)"
        }
    }

    /// Delete a form
    func delete(_ form: FilledForm) {
        guard let context = modelContext else { return }

        context.delete(form)

        do {
            try context.save()
            loadForms()
        } catch {
            errorMessage = "Silme hatası: \(error.localizedDescription)"
        }
    }

    /// Update an existing form
    func update(_ form: FilledForm) {
        form.lastModified = Date()
        save(form)
    }

    /// Get forms for a specific category
    func getForms(forCategory category: String, level: String? = nil) -> [FilledForm] {
        // This would need template manager to check template category
        // For now, return all forms
        filledForms
    }

    /// Get form by ID
    func getForm(id: UUID) -> FilledForm? {
        filledForms.first { $0.id == id }
    }

    /// Get forms for a specific template
    func getForms(forTemplateId templateId: String) -> [FilledForm] {
        filledForms.filter { $0.templateId == templateId }
    }

    /// Delete multiple forms
    func deleteForms(_ forms: [FilledForm]) {
        guard let context = modelContext else { return }

        for form in forms {
            context.delete(form)
        }

        do {
            try context.save()
            loadForms()
        } catch {
            errorMessage = "Toplu silme hatası: \(error.localizedDescription)"
        }
    }

    // MARK: - Role-based filtering methods

    /// Get forms created by a specific user (for Müteahhit to see their own forms)
    func getMyForms(username: String) -> [FilledForm] {
        filledForms.filter { $0.createdByUsername == username }
    }

    /// Get forms pending Müşavir approval (for Müşavir role)
    func getFormsForMusavirApproval() -> [FilledForm] {
        filledForms.filter { $0.approvalStatus == .pendingMusavir }
    }

    /// Get forms pending İşVeren approval (for İşVeren role)
    func getFormsForIsverenApproval() -> [FilledForm] {
        filledForms.filter { $0.approvalStatus == .pendingIsveren }
    }

    /// Get fully approved forms
    func getApprovedForms() -> [FilledForm] {
        filledForms.filter { $0.approvalStatus == .approved }
    }

    /// Get approved forms by category
    func getApprovedForms(category: String) -> [FilledForm] {
        // We'll need template manager to filter by category
        getApprovedForms()
    }

    /// Approve form as Müşavir
    func approveAsMusavir(_ form: FilledForm, approvedBy: String) {
        guard form.approvalStatus == .pendingMusavir else { return }

        form.musavirApprovedBy = approvedBy
        form.musavirApprovedDate = Date()
        form.approvalStatus = .pendingIsveren
        update(form)
    }

    /// Approve form as İşVeren
    func approveAsIsveren(_ form: FilledForm, approvedBy: String) {
        guard form.approvalStatus == .pendingIsveren else { return }

        form.isverenApprovedBy = approvedBy
        form.isverenApprovedDate = Date()
        form.approvalStatus = .approved
        update(form)
    }

    /// Submit form for approval (Müteahhit saves and submits)
    func submitForApproval(_ form: FilledForm) {
        form.approvalStatus = .pendingMusavir
        update(form)
    }
}
