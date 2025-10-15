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
                print("  - \(job.name): scheduled=\(job.scheduledDate ?? "nil"), created=\(job.createdAt ?? "nil")")
            }
            
            jobs = fetchedJobs.sorted { job1, job2 in
                // Sort by scheduled date ascending, with nil dates at the end
                switch (job1.scheduledDate, job2.scheduledDate) {
                case (nil, nil):
                    // Both nil: sort by created date as fallback
                    if let created1 = job1.createdAt, let created2 = job2.createdAt {
                        return parseDate(created1) < parseDate(created2)
                    }
                    return false
                case (nil, _):
                    return false  // job1 has nil date, goes to end
                case (_, nil):
                    return true   // job2 has nil date, job1 comes first
                case (let date1?, let date2?):
                    let parsedDate1 = parseDate(date1)
                    let parsedDate2 = parseDate(date2)
                    print("📱 Comparing dates: \(date1) (\(parsedDate1)) vs \(date2) (\(parsedDate2))")
                    return parsedDate1 < parsedDate2
                }
            }
            
            // Debug: Print job dates after sorting
            print("📱 JobsViewModel: Jobs after sorting:")
            for job in jobs {
                print("  - \(job.name): scheduled=\(job.scheduledDate ?? "nil")")
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
        // Try ISO8601 format first
        let iso8601Formatter = ISO8601DateFormatter()
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        
        // Try alternative formats
        let dateFormatter = DateFormatter()
        
        // Try "yyyy-MM-dd HH:mm:ss" format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        // Try "yyyy-MM-dd" format
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        print("⚠️ Could not parse date: \(dateString)")
        return Date.distantFuture // Put unparseable dates at the end
    }
}

