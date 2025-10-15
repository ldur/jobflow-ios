//
//  JobsViewModel.swift
//  JobFlow
//
//  ViewModel for jobs list
//

import Foundation
import Combine

@MainActor
class JobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: JobStatus?
    
    private let supabaseService = SupabaseService.shared
    
    var filteredJobs: [Job] {
        let filtered = selectedStatus != nil ? jobs.filter { $0.statusEnum == selectedStatus } : jobs
        return filtered.sorted { job1, job2 in
            // Sort by scheduled date ascending, with nil dates at the end
            switch (job1.scheduledDate, job2.scheduledDate) {
            case (nil, nil):
                return false
            case (nil, _):
                return false
            case (_, nil):
                return true
            case (let date1?, let date2?):
                return parseDate(date1) < parseDate(date2)
            }
        }
    }
    
    func loadJobs() async {
        isLoading = true
        errorMessage = nil
        
        print("📱 JobsViewModel: Starting to load jobs...")
        
        do {
            let fetchedJobs = try await supabaseService.fetchJobs()
            jobs = fetchedJobs.sorted { job1, job2 in
                // Sort by scheduled date ascending, with nil dates at the end
                switch (job1.scheduledDate, job2.scheduledDate) {
                case (nil, nil):
                    return false
                case (nil, _):
                    return false
                case (_, nil):
                    return true
                case (let date1?, let date2?):
                    return parseDate(date1) < parseDate(date2)
                }
            }
            print("📱 JobsViewModel: Loaded \(jobs.count) jobs successfully")
        } catch {
            print("📱 JobsViewModel: Error loading jobs - \(error)")
            errorMessage = error.localizedDescription
            print("📱 JobsViewModel: Error message set to: \(error.localizedDescription)")
        }
        
        isLoading = false
        print("📱 JobsViewModel: Loading complete. Jobs count: \(jobs.count)")
    }
    
    func refreshJobs() async {
        await loadJobs()
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
}

