//
//  JobsViewModel.swift
//  KindredFlowGraphiOS
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
        
        do {
            jobs = try await supabaseService.fetchJobs()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshJobs() async {
        await loadJobs()
    }
}

