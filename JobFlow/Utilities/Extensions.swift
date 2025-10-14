//
//  Extensions.swift
//  JobFlow
//
//  Utility extensions
//

import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func toISO8601String() -> String {
        return ISO8601DateFormatter().string(from: self)
    }
    
    static func fromISO8601String(_ string: String) -> Date? {
        return ISO8601DateFormatter().date(from: string)
    }
}

// MARK: - String Extensions
extension String {
    func toDate() -> Date? {
        return Date.fromISO8601String(self)
    }
}

// MARK: - Color Extensions
extension Color {
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

