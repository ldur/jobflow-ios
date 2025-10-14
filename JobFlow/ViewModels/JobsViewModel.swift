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
        guard let selectedStatus = selectedStatus else {
            return jobs
        }
        return jobs.filter { $0.statusEnum == selectedStatus }
    }
    
    func loadJobs() async {
        isLoading = true
        errorMessage = nil
        
        print("📱 JobsViewModel: Starting to load jobs...")
        
        do {
            jobs = try await supabaseService.fetchJobs()
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

