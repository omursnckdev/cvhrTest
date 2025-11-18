//
//  UserManager.swift
//  TestFormApp
//
//  Manages user authentication and current session
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Sign up a new user
    func signUp(username: String, password: String, fullName: String, role: UserRole) throws {
        // Check if username already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.username == username }
        )

        let existingUsers = try modelContext.fetch(descriptor)
        if !existingUsers.isEmpty {
            throw AuthError.usernameExists
        }

        // Create new user
        let newUser = User(username: username, password: password, fullName: fullName, role: role)
        modelContext.insert(newUser)
        try modelContext.save()

        // Auto-login after signup
        currentUser = newUser
        isAuthenticated = true
    }

    /// Log in an existing user
    func login(username: String, password: String) throws {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.username == username }
        )

        let users = try modelContext.fetch(descriptor)
        guard let user = users.first else {
            throw AuthError.invalidCredentials
        }

        guard user.password == password else {
            throw AuthError.invalidCredentials
        }

        currentUser = user
        isAuthenticated = true
    }

    /// Log out the current user
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }

    /// Check if current user has permission for specific action
    func hasPermission(_ permission: Permission) -> Bool {
        guard let user = currentUser else { return false }

        switch permission {
        case .createForms:
            return user.role.canCreateForms
        case .approveAsMusavir:
            return user.role.canApproveAsMusavir
        case .approveAsIsveren:
            return user.role.canApproveAsIsveren
        }
    }
}

/// Authentication errors
enum AuthError: LocalizedError {
    case usernameExists
    case invalidCredentials
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .usernameExists:
            return "Bu kullanıcı adı zaten kullanılıyor"
        case .invalidCredentials:
            return "Kullanıcı adı veya şifre hatalı"
        case .notAuthenticated:
            return "Lütfen giriş yapın"
        }
    }
}

/// Permissions enum for role-based access control
enum Permission {
    case createForms
    case approveAsMusavir
    case approveAsIsveren
}
