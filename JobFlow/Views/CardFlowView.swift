//
//  CardFlowView.swift
//  JobFlow
//
//  Card-by-card view for activities with swipe gestures
//

import SwiftUI

struct CardFlowView: View {
    @StateObject private var viewModel: CardFlowViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var notesText = ""
    @State private var isEditingNotes = false
    @Environment(\.dismiss) private var dismiss
    
    init(jobId: String, jobName: String) {
        _viewModel = StateObject(wrappedValue: CardFlowViewModel(jobId: jobId, jobName: jobName))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading activities...")
                } else if viewModel.allActivities.isEmpty {
                    emptyStateView
                } else if let card = viewModel.currentCard {
                    VStack(spacing: 0) {
                        // Progress bar
                        progressBar
                        
                        // Card content with drag gesture and visual feedback
                        ZStack {
                            // Swipe feedback overlays behind the card
                            if abs(dragOffset) > 20 {
                                if dragOffset > 0 && viewModel.hasPrevious {
                                    // Swiping right (previous)
                                    HStack {
                                        VStack(spacing: 8) {
                                            Image(systemName: "chevron.left.circle.fill")
                                                .font(.system(size: 60))
                                            Text("Previous")
                                                .font(.headline)
                                        }
                                        .foregroundColor(.blue)
                                        .opacity(min(Double(dragOffset) / 150, 1.0))
                                        Spacer()
                                    }
                                    .padding(40)
                                } else if dragOffset < 0 && viewModel.hasNext {
                                    // Swiping left (next & complete)
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 60))
                                            Text("Complete & Next")
                                                .font(.headline)
                                        }
                                        .foregroundColor(.green)
                                        .opacity(min(Double(-dragOffset) / 150, 1.0))
                                    }
                                    .padding(40)
                                }
                            }
                            
                            cardContent(card: card)
                        }
                        .offset(x: dragOffset)
                        .opacity(1.0 - Double(abs(dragOffset)) / 500)
                        .rotationEffect(.degrees(Double(dragOffset) / 30))
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { value in
                                    // Only respond to mostly horizontal drags
                                    let horizontalAmount = abs(value.translation.width)
                                    let verticalAmount = abs(value.translation.height)
                                    
                                    if horizontalAmount > verticalAmount * 1.5 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    let horizontalAmount = abs(value.translation.width)
                                    let verticalAmount = abs(value.translation.height)
                                    
                                    // Only trigger swipe if mostly horizontal
                                    if horizontalAmount > verticalAmount * 1.5 {
                                        handleSwipe(translation: value.translation.width)
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .navigationTitle(viewModel.jobName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                await viewModel.loadActivities()
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Activity \(viewModel.currentIndex + 1) of \(viewModel.allActivities.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.progress)
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Card Content
    
    private func cardContent(card: ActivityCard) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Job name badge
                HStack {
                    Image(systemName: "folder.fill")
                    Text(card.jobName)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
                
                // Activity name
                Text(card.actionName)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                // Step indicator
                Text("Step \(card.sequenceOrder)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Text-to-speech button for action name and description
                TextToSpeechButton(
                    text: buildSpeechText(for: card),
                    style: .full
                )
                .padding(.horizontal)
                
                // Description
                if let description = card.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Media files
                if let media = viewModel.actionMedia[card.actionName], !media.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Media Files")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        
                        ForEach(media) { mediaItem in
                            InlineMediaView(media: mediaItem)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Notes section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                        Text("Notes")
                            .fontWeight(.semibold)
                        Spacer()
                        SpeechToTextButton(text: $notesText, placeholder: "Add notes...")
                    }
                    .foregroundColor(.secondary)
                    
                    if isEditingNotes {
                        VStack(spacing: 12) {
                            TextEditor(text: $notesText)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            HStack(spacing: 12) {
                                Button {
                                    notesText = card.notes ?? ""
                                    isEditingNotes = false
                                } label: {
                                    Text("Cancel")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                                
                                Button {
                                    Task {
                                        await viewModel.updateNotes(notesText)
                                        isEditingNotes = false
                                    }
                                } label: {
                                    Text("Save")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    } else {
                        Button {
                            notesText = card.notes ?? ""
                            isEditingNotes = true
                        } label: {
                            HStack {
                                Text(card.notes ?? "Tap to add notes...")
                                    .foregroundColor(card.notes == nil ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Complete button
                Button {
                    Task {
                        await viewModel.markCurrentAsComplete()
                    }
                } label: {
                    HStack {
                        Image(systemName: card.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                        Text(card.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(card.isCompleted ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
        .contentShape(Rectangle())
        .onChange(of: card.id) { _ in
            notesText = card.notes ?? ""
            isEditingNotes = false
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Activities")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You don't have any activities to work on")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    private func buildSpeechText(for card: ActivityCard) -> String {
        var speechText = "Step \(card.sequenceOrder): \(card.actionName)"
        
        if let description = card.description, !description.isEmpty {
            speechText += ". \(description)"
        }
        
        if let notes = card.notes, !notes.isEmpty {
            speechText += ". Notes: \(notes)"
        }
        
        return speechText
    }
    
    // MARK: - Swipe Handler
    
    private func handleSwipe(translation: CGFloat) {
        let threshold: CGFloat = 80
        
        Task {
            if translation > threshold && viewModel.hasPrevious {
                // Swipe right - go to previous (no auto-complete)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.previousCard()
                    dragOffset = 0
                }
            } else if translation < -threshold && viewModel.hasNext {
                // Swipe left - go to next (with auto-complete)
                await viewModel.nextCard(autoComplete: true)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = 0
                }
            } else {
                // Snap back if threshold not met
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = 0
                }
            }
        }
    }
}

#Preview {
    CardFlowView(jobId: "preview-id", jobName: "Sample Job")
}

