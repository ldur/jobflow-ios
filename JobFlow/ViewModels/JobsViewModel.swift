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
        // Jobs are already sorted by scheduled date in loadJobs(), just return filtered
        return filtered
    }
    
    func loadJobs() async {
        isLoading = true
        errorMessage = nil
        
        print("📱 JobsViewModel: Starting to load jobs...")
        
        do {
            let fetchedJobs = try await supabaseService.fetchJobs()
            
            // Debug: Print job dates before sorting
            print("📱 JobsViewModel: Jobs before sorting:")
            for job in fetchedJobs {
                print("  - \(job.name): scheduled=\(job.scheduledDate ?? "nil") -> \(job.scheduledDateAsDate)")
            }
            
            // Sort by scheduled date using the computed property
            jobs = fetchedJobs.sorted { job1, job2 in
                return job1.scheduledDateAsDate < job2.scheduledDateAsDate
            }
            
            // Debug: Print job dates after sorting
            print("📱 JobsViewModel: Jobs after sorting by scheduled date:")
            for job in jobs {
                print("  - \(job.name): scheduled=\(job.scheduledDate ?? "nil") -> \(job.scheduledDateAsDate)")
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
    

}

