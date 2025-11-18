//
//  User.swift
//  TestFormApp
//
//  Created by Claude on 18/11/2025.
//

import Foundation
import SwiftData

/// User roles in the approval workflow
enum UserRole: String, Codable, CaseIterable {
    case muteahhit = "Müteahhit"    // Contractor - creates and fills forms
    case musavir = "Müşavir"        // Consultant - reviews and approves forms
    case isveren = "İşVeren"        // Employer - final approval

    var description: String {
        self.rawValue
    }

    /// Permissions for each role
    var canCreateForms: Bool {
        return self == .muteahhit
    }

    var canApproveAsMusavir: Bool {
        return self == .musavir
    }

    var canApproveAsIsveren: Bool {
        return self == .isveren
    }
}

/// User model for authentication and role-based access
@Model
final class User {
    @Attribute(.unique) var username: String
    var password: String // In production, this should be hashed
    var fullName: String
    var roleRawValue: String
    var createdAt: Date

    /// Computed property for UserRole
    var role: UserRole {
        get {
            UserRole(rawValue: roleRawValue) ?? .muteahhit
        }
        set {
            roleRawValue = newValue.rawValue
        }
    }

    init(username: String, password: String, fullName: String, role: UserRole) {
        self.username = username
        self.password = password
        self.fullName = fullName
        self.roleRawValue = role.rawValue
        self.createdAt = Date()
    }
}
