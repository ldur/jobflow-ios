//
//  CardFlowViewModel.swift
//  JobFlow
//
//  ViewModel for card-by-card activity flow
//

import Foundation
import Combine

@MainActor
class CardFlowViewModel: ObservableObject {
    @Published var allActivities: [ActivityCard] = []
    @Published var currentIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let jobId: String
    let jobName: String
    
    private let supabaseService = SupabaseService.shared
    
    init(jobId: String, jobName: String) {
        self.jobId = jobId
        self.jobName = jobName
    }
    
    var currentCard: ActivityCard? {
        guard currentIndex < allActivities.count else { return nil }
        return allActivities[currentIndex]
    }
    
    var hasNext: Bool {
        currentIndex < allActivities.count - 1
    }
    
    var hasPrevious: Bool {
        currentIndex > 0
    }
    
    var progress: Double {
        guard !allActivities.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(allActivities.count)
    }
    
    func loadActivities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let job = try await supabaseService.fetchJobById(jobId)
            
            // Get actions for this specific job
            var cards: [ActivityCard] = []
            
            if let actions = job.actions {
                for action in actions {
                    cards.append(ActivityCard(
                        id: action.id,
                        jobId: job.id,
                        jobName: job.name,
                        actionName: action.name,
                        description: action.description,
                        sequenceOrder: action.sequenceOrder,
                        isCompleted: action.isCompleted,
                        notes: action.notes,
                        status: action.status ?? "pending"
                    ))
                }
            }
            
            // Sort by sequence order
            allActivities = cards.sorted { $0.sequenceOrder < $1.sequenceOrder }
            
            // Set initial index to first incomplete activity
            if let firstIncompleteIndex = allActivities.firstIndex(where: { !$0.isCompleted }) {
                currentIndex = firstIncompleteIndex
                print("📋 Loaded \(allActivities.count) activity cards. Starting at first incomplete: index \(firstIncompleteIndex)")
            } else {
                currentIndex = 0
                print("📋 Loaded \(allActivities.count) activity cards. All completed, starting at beginning")
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading activities: \(error)")
        }
        
        isLoading = false
    }
    
    func nextCard(autoComplete: Bool = false) async {
        if hasNext {
            // Auto-complete current card when moving forward if requested
            if autoComplete, let currentCard = currentCard, !currentCard.isCompleted {
                await markAsComplete(card: currentCard)
            }
            
            currentIndex += 1
        }
    }
    
    func previousCard() {
        if hasPrevious {
            currentIndex -= 1
        }
    }
    
    func markCurrentAsComplete() async {
        guard let card = currentCard else { return }
        await markAsComplete(card: card)
    }
    
    private func markAsComplete(card: ActivityCard) async {
        do {
            let newStatus = card.isCompleted ? "pending" : "completed"
            try await supabaseService.updateJobAction(
                actionId: card.id,
                status: newStatus,
                completedAt: newStatus == "completed" ? ISO8601DateFormatter().string(from: Date()) : nil
            )
            
            // Update local state
            if let index = allActivities.firstIndex(where: { $0.id == card.id }) {
                allActivities[index].isCompleted = !card.isCompleted
                allActivities[index].status = newStatus
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateNotes(_ notes: String) async {
        guard let card = currentCard else { return }
        
        do {
            try await supabaseService.updateJobAction(
                actionId: card.id,
                notes: notes.isEmpty ? nil : notes
            )
            
            // Update local state
            if let index = allActivities.firstIndex(where: { $0.id == card.id }) {
                allActivities[index].notes = notes.isEmpty ? nil : notes
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Activity Card Model
struct ActivityCard: Identifiable, Equatable {
    let id: String
    let jobId: String
    let jobName: String
    let actionName: String
    let description: String?
    let sequenceOrder: Int
    var isCompleted: Bool
    var notes: String?
    var status: String
}

