//
//  JobDetailView.swift
//  JobFlow
//
//  Detailed view for a single job with actions
//

import SwiftUI

struct JobDetailView: View {
    let jobId: String
    @StateObject private var viewModel: JobDetailViewModel
    @State private var showCompleteAlert = false
    @State private var actionToComplete: JobActionInstance?
    
    init(jobId: String) {
        self.jobId = jobId
        _viewModel = StateObject(wrappedValue: JobDetailViewModel(jobId: jobId))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.job == nil {
                ProgressView("Loading job details...")
            } else if let job = viewModel.job {
                ScrollView {
                    VStack(spacing: 20) {
                        // Job header
                        jobHeaderView(job: job)
                        
                        // Actions list
                        if !viewModel.jobActions.isEmpty {
                            actionsListView
                        } else {
                            Text("No actions for this job")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding()
                }
                .navigationTitle(job.name)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.loadJobDetails()
        }
        .alert("Complete Job Here", isPresented: $showCompleteAlert) {
            Button("Cancel", role: .cancel) {
                actionToComplete = nil
            }
            Button("Complete", role: .destructive) {
                if let action = actionToComplete {
                    Task {
                        await viewModel.completeJobHere(action: action)
                        actionToComplete = nil
                    }
                }
            }
        } message: {
            Text("This will mark this action and all subsequent actions as completed. This action cannot be undone. Are you sure?")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func jobHeaderView(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                JobStatusBadge(status: job.statusEnum)
                Spacer()
            }
            
            if let templateName = job.processTemplate?.name {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Template")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(templateName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            if let description = job.processTemplate?.description {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(description)
                        .font(.subheadline)
                }
            }
            
            ProgressView(value: job.completionPercentage)
                .tint(.blue)
            
            let completedCount = viewModel.jobActions.filter { $0.isCompleted }.count
            Text("\(completedCount)/\(viewModel.jobActions.count) actions completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var actionsListView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Actions")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ForEach(Array(viewModel.jobActions.enumerated()), id: \.element.id) { index, action in
                ActionCardView(
                    action: action,
                    stepNumber: index + 1,
                    media: viewModel.actionMedia[action.name] ?? [],
                    canComplete: viewModel.canCompleteActionInSequence(action),
                    isStrictSequence: viewModel.job?.strictSequence ?? false,
                    hasSubsequentActions: viewModel.jobActions.contains { $0.sequenceOrder > action.sequenceOrder },
                    onToggle: {
                        Task {
                            await viewModel.toggleActionStatus(action: action)
                        }
                    },
                    onNotesUpdate: { notes in
                        Task {
                            await viewModel.updateActionNotes(action: action, notes: notes)
                        }
                    },
                    onCompleteJobHere: {
                        actionToComplete = action
                        showCompleteAlert = true
                    }
                )
            }
        }
    }
}

struct ActionCardView: View {
    let action: JobActionInstance
    let stepNumber: Int
    let media: [ActionMedia]
    let canComplete: Bool
    let isStrictSequence: Bool
    let hasSubsequentActions: Bool
    let onToggle: () -> Void
    let onNotesUpdate: (String) -> Void
    let onCompleteJobHere: () -> Void
    
    @State private var notesText: String

    
    init(action: JobActionInstance, stepNumber: Int, media: [ActionMedia], canComplete: Bool, isStrictSequence: Bool, hasSubsequentActions: Bool, onToggle: @escaping () -> Void, onNotesUpdate: @escaping (String) -> Void, onCompleteJobHere: @escaping () -> Void) {
        self.action = action
        self.stepNumber = stepNumber
        self.media = media
        self.canComplete = canComplete
        self.isStrictSequence = isStrictSequence
        self.hasSubsequentActions = hasSubsequentActions
        self.onToggle = onToggle
        self.onNotesUpdate = onNotesUpdate
        self.onCompleteJobHere = onCompleteJobHere
        _notesText = State(initialValue: action.notes ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Status icon
                Image(systemName: action.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(action.isCompleted ? .green : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Step \(stepNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if isStrictSequence && !canComplete && !action.isCompleted {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(action.name)
                        .font(.headline)
                    
                    if let description = action.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let completedAt = action.completedAt {
                        Text("Completed: \(formatDate(completedAt))")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Checkbox
                Button {
                    onToggle()
                } label: {
                    Image(systemName: action.isCompleted ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(canComplete ? .blue : .gray)
                }
                .disabled(!canComplete && !action.isCompleted)
            }
            
            // Media
            if !media.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Media Files")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(media) { mediaItem in
                        InlineMediaView(media: mediaItem)
                    }
                }
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $notesText)
                    .frame(height: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: notesText) { newValue in
                        onNotesUpdate(newValue)
                    }
            }
            
            // Complete Job Here button
            if !action.isCompleted && hasSubsequentActions {
                Button {
                    onCompleteJobHere()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.square")
                        Text("Complete Job Here")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(action.isCompleted ? Color.green.opacity(0.05) : Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(action.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)

    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}



#Preview {
    JobDetailView(jobId: "test-id")
}

