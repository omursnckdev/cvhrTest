//
//  Extensions.swift
//  TestFormApp
//
//  Utility extensions
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }

    func formattedWithTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions

extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        }
        return self
    }
}

// MARK: - View Extensions

extension View {
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static let formBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)

    /// Get color for checklist status
    static func forCheckStatus(_ status: CheckStatus) -> Color {
        switch status {
        case .unchecked:
            return .gray
        case .yes:
            return .green
        case .no:
            return .red
        case .notApplicable:
            return .orange
        }
    }

    /// Get color for dependency severity
    static func forSeverity(_ severity: DependencySeverity) -> Color {
        switch severity {
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    /// Decode JSON from bundle
    func decode<T: Decodable>(_ type: T.Type, from file: String) throws -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to locate \(file) in bundle."
                )
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
