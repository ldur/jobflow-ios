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
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            JobsListView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Jobs")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseService.shared)
}

