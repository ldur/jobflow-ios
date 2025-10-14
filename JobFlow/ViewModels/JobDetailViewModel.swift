//
//  JobDetailViewModel.swift
//  JobFlow
//
//  ViewModel for job detail view
//

import Foundation
import Combine

@MainActor
class JobDetailViewModel: ObservableObject {
    @Published var job: Job?
    @Published var jobActions: [JobActionInstance] = []
    @Published var actionMedia: [String: [ActionMedia]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    private let jobId: String
    
    init(jobId: String) {
        self.jobId = jobId
    }
    
    func loadJobDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load job
            job = try await supabaseService.fetchJobById(jobId)
            
            // Load job actions
            jobActions = try await supabaseService.fetchJobActions(jobId: jobId)
            
            // Load media for actions
            if !jobActions.isEmpty {
                let actionNames = jobActions.map { $0.name }
                actionMedia = try await supabaseService.fetchActionMedia(actionNames: actionNames)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleActionStatus(action: JobActionInstance) async {
        let newStatus = action.isCompleted ? "pending" : "completed"
        
        // Validate strict sequence if needed
        if newStatus == "completed", let job = job, job.strictSequence == true {
            let incompletePrevious = jobActions.contains { otherAction in
                otherAction.sequenceOrder < action.sequenceOrder && !otherAction.isCompleted
            }
            
            if incompletePrevious {
                errorMessage = "Please complete previous actions first (strict sequence mode)"
                return
            }
        }
        
        let completedAt = newStatus == "completed" ? ISO8601DateFormatter().string(from: Date()) : nil
        
        do {
            try await supabaseService.updateJobAction(
                actionId: action.id,
                status: newStatus,
                completedAt: completedAt
            )
            
            // Update local state
            if let index = jobActions.firstIndex(where: { $0.id == action.id }) {
                let updatedAction = jobActions[index]
                jobActions[index] = JobActionInstance(
                    id: updatedAction.id,
                    jobId: updatedAction.jobId,
                    name: updatedAction.name,
                    description: updatedAction.description,
                    sequenceOrder: updatedAction.sequenceOrder,
                    status: newStatus,
                    notes: updatedAction.notes,
                    completedAt: completedAt,
                    createdAt: updatedAction.createdAt
                )
            }
            
            // Check if job is complete
            let allCompleted = jobActions.allSatisfy { $0.isCompleted }
            if allCompleted, let job = job, job.status != "completed" {
                try await supabaseService.updateJobStatus(
                    jobId: jobId,
                    status: "completed",
                    completedAt: ISO8601DateFormatter().string(from: Date())
                )
            }
            
            // Reload to get fresh data
            await loadJobDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateActionNotes(action: JobActionInstance, notes: String) async {
        do {
            try await supabaseService.updateJobAction(actionId: action.id, notes: notes)
            
            // Update local state
            if let index = jobActions.firstIndex(where: { $0.id == action.id }) {
                let updatedAction = jobActions[index]
                jobActions[index] = JobActionInstance(
                    id: updatedAction.id,
                    jobId: updatedAction.jobId,
                    name: updatedAction.name,
                    description: updatedAction.description,
                    sequenceOrder: updatedAction.sequenceOrder,
                    status: updatedAction.status,
                    notes: notes,
                    completedAt: updatedAction.completedAt,
                    createdAt: updatedAction.createdAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func completeJobHere(action: JobActionInstance) async {
        let subsequentActions = jobActions.filter { $0.sequenceOrder > action.sequenceOrder }
        
        do {
            try await supabaseService.completeJobFromAction(
                jobId: jobId,
                actionId: action.id,
                actionName: action.name,
                subsequentActions: subsequentActions
            )
            
            // Reload to get fresh data
            await loadJobDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func canCompleteActionInSequence(_ action: JobActionInstance) -> Bool {
        guard let job = job, job.strictSequence == true else {
            return true
        }
        
        if action.isCompleted {
            return true
        }
        
        return !jobActions.contains { otherAction in
            otherAction.sequenceOrder < action.sequenceOrder && !otherAction.isCompleted
        }
    }
}

