//
//  Config.swift
//  JobFlow
//
//  Configuration values loaded from Config.xcconfig
//

import Foundation

enum Config {
    /// Supabase URL from build configuration
    static let supabaseURL: String = {
        // Try to read from build settings first
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"], !url.isEmpty {
            return url
        }
        // Fallback to reading from a generated file or hardcoded value
        // This will be populated during build from Config.xcconfig
        #if DEBUG
        return "https://wsyesbilttvqqfxkhbzc.supabase.co"
        #else
        return "https://wsyesbilttvqqfxkhbzc.supabase.co"
        #endif
    }()
    
    /// Supabase Anonymous Key from build configuration
    static let supabaseAnonKey: String = {
        // Try to read from build settings first
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"], !key.isEmpty {
            return key
        }
        // Fallback to reading from a generated file or hardcoded value
        // This will be populated during build from Config.xcconfig
        #if DEBUG
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzeWVzYmlsdHR2cXFmeGtoYnpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NzY0NjUsImV4cCI6MjA3NTQ1MjQ2NX0.QOrkuOGyPmMWvu40CQpP64AU3NUd-aasB9QScQnad4M"
        #else
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzeWVzYmlsdHR2cXFmeGtoYnpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NzY0NjUsImV4cCI6MjA3NTQ1MjQ2NX0.QOrkuOGyPmMWvu40CQpP64AU3NUd-aasB9QScQnad4M"
        #endif
    }()
}

