//
//  JobFlowApp.swift
//  JobFlow
//
//  Main app entry point
//

import SwiftUI

@main
struct JobFlowApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseService)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var supabaseService: SupabaseService
    
    var body: some View {
        Group {
            if supabaseService.isAuthenticated {
                JobsListView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseService.shared)
}

