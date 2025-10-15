//
//  JobsListView.swift
//  JobFlow
//
//  List view for all jobs assigned to user
//

import SwiftUI

enum JobViewMode: CaseIterable {
    case list
    case card
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .card: return "square.grid.2x2"
        }
    }
    
    var title: String {
        switch self {
        case .list: return "List"
        case .card: return "Cards"
        }
    }
}

struct JobsListView: View {
    @StateObject private var viewModel = JobsViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingProfile = false
    @State private var selectedJob: Job?
    @State private var selectedJobForCardView: Job?
    @State private var viewMode: JobViewMode = .list
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    ProgressView("Loading jobs...")
                } else if viewModel.jobs.isEmpty {
                    emptyStateView
                } else {
                    if viewMode == .list {
                        jobsListView
                    } else {
                        jobsCardView
                    }
                }
            }
            .navigationTitle("My Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            viewModel.selectedStatus = nil
                        } label: {
                            HStack {
                                if viewModel.selectedStatus == nil {
                                    Image(systemName: "checkmark")
                                }
                                Text("All Jobs")
                            }
                        }
                        
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            Button {
                                viewModel.selectedStatus = status
                            } label: {
                                HStack {
                                    if viewModel.selectedStatus == status {
                                        Image(systemName: "checkmark")
                                    }
                                    Text(status.displayName)
                                }
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // View mode toggle
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewMode = viewMode == .list ? .card : .list
                            }
                        } label: {
                            Image(systemName: viewMode.icon)
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            showingProfile = true
                        } label: {
                            Label("Profile", systemImage: "person.circle")
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshJobs()
            }
            .task {
                await viewModel.loadJobs()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(item: $selectedJob) { job in
                NavigationView {
                    JobDetailView(jobId: job.id)
                }
            }
            .onChange(of: selectedJob) { newValue in
                // Refresh jobs when detail view is closed
                if newValue == nil {
                    Task {
                        await viewModel.refreshJobs()
                    }
                }
            }
            .fullScreenCover(item: $selectedJobForCardView) { job in
                CardFlowView(jobId: job.id, jobName: job.name)
            }
            .onChange(of: selectedJobForCardView) { newValue in
                // Refresh jobs when card view is closed
                if newValue == nil {
                    Task {
                        await viewModel.refreshJobs()
                    }
                }
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
    }
    
    private var jobsListView: some View {
        List {
            if let selectedStatus = viewModel.selectedStatus {
                Section {
                    ForEach(viewModel.filteredJobs) { job in
                        JobRowView(
                            job: job,
                            onListViewTap: { selectedJob = job },
                            onCardViewTap: { selectedJobForCardView = job }
                        )
                    }
                } header: {
                    Text("\(selectedStatus.displayName) Jobs")
                }
            } else {
                ForEach(JobStatus.allCases, id: \.self) { status in
                    let jobsForStatus = viewModel.jobs.filter { $0.statusEnum == status }
                    if !jobsForStatus.isEmpty {
                        Section {
                            ForEach(jobsForStatus) { job in
                                JobRowView(
                                    job: job,
                                    onListViewTap: { selectedJob = job },
                                    onCardViewTap: { selectedJobForCardView = job }
                                )
                            }
                        } header: {
                            Text(status.displayName)
                        }
                    }
                }
            }
        }
    }
    
    private var jobsCardView: some View {
        List {
            if let selectedStatus = viewModel.selectedStatus {
                Section {
                    ForEach(viewModel.filteredJobs) { job in
                        JobCardRowView(
                            job: job,
                            onListViewTap: { selectedJob = job },
                            onCardViewTap: { selectedJobForCardView = job }
                        )
                    }
                } header: {
                    Text("\(selectedStatus.displayName) Jobs")
                }
            } else {
                ForEach(JobStatus.allCases, id: \.self) { status in
                    let jobsForStatus = viewModel.jobs.filter { $0.statusEnum == status }
                    if !jobsForStatus.isEmpty {
                        Section {
                            ForEach(jobsForStatus) { job in
                                JobCardRowView(
                                    job: job,
                                    onListViewTap: { selectedJob = job },
                                    onCardViewTap: { selectedJobForCardView = job }
                                )
                            }
                        } header: {
                            Text(status.displayName)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Jobs")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You don't have any jobs assigned yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.refreshJobs()
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct JobRowView: View {
    let job: Job
    let onListViewTap: () -> Void
    let onCardViewTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Job status indicator
            Circle()
                .fill(statusColor(for: job.statusEnum))
                .frame(width: 12, height: 12)
            
            // Job info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(job.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Progress indicator
                    if let actions = job.actions {
                        let completedCount = actions.filter { $0.isCompleted }.count
                        Text("\(completedCount)/\(actions.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if let templateName = job.processTemplate?.name {
                        Text(templateName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    JobStatusBadge(status: job.statusEnum)
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                // TTS button
                TextToSpeechButton(
                    text: buildJobSpeechText(for: job),
                    style: .icon
                )
                
                // Details button
                Button(action: onListViewTap) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                // Card view button
                Button(action: onCardViewTap) {
                    Image(systemName: "rectangle.stack")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private func statusColor(for status: JobStatus) -> Color {
        switch status {
        case .ready: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
    
    private func buildJobSpeechText(for job: Job) -> String {
        var speechText = "Job: \(job.name)"
        
        if let templateName = job.processTemplate?.name {
            speechText += ". Template: \(templateName)"
        }
        
        if let description = job.processTemplate?.description {
            speechText += ". \(description)"
        }
        
        speechText += ". Status: \(job.statusEnum.displayName)"
        
        if let actions = job.actions {
            let completedCount = actions.filter { $0.isCompleted }.count
            speechText += ". Progress: \(completedCount) of \(actions.count) actions completed"
        }
        
        return speechText
    }
}

struct JobCardRowView: View {
    let job: Job
    let onListViewTap: () -> Void
    let onCardViewTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.name)
                        .font(.headline)
                    
                    // Text-to-speech button for job
                    TextToSpeechButton(
                        text: buildJobSpeechText(for: job),
                        style: .compact
                    )
                }
                
                Spacer()
                
                JobStatusBadge(status: job.statusEnum)
            }
            
            if let templateName = job.processTemplate?.name {
                Text(templateName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let scheduledDate = job.scheduledDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDate(scheduledDate))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: job.completionPercentage)
                .tint(progressColor(for: job.statusEnum))
            
            HStack {
                if let actions = job.actions {
                    let completedCount = actions.filter { $0.isCompleted }.count
                    Text("\(completedCount)/\(actions.count) actions completed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Media preview section
            if let actions = job.actions, !actions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.caption)
                        Text("Actions with Media")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(actions.count) steps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.blue)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(actions.prefix(5).enumerated()), id: \.element.id) { index, action in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(action.isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                        .frame(width: 40, height: 30)
                                        .overlay(
                                            Image(systemName: action.isCompleted ? "checkmark" : "circle")
                                                .font(.caption2)
                                                .foregroundColor(action.isCompleted ? .green : .red)
                                        )
                                    
                                    Text("\(index + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if actions.count > 5 {
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 30)
                                        .overlay(
                                            Text("+\(actions.count - 5)")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        )
                                    
                                    Text("more")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
            
            // View mode buttons
            HStack(spacing: 12) {
                Button(action: onListViewTap) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("List View")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: onCardViewTap) {
                    HStack {
                        Image(systemName: "square.stack.3d.up.fill")
                        Text("Card View")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
    
    private func progressColor(for status: JobStatus) -> Color {
        switch status {
        case .ready: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
    
    private func buildJobSpeechText(for job: Job) -> String {
        var speechText = "Job: \(job.name)"
        
        if let templateName = job.processTemplate?.name {
            speechText += ". Template: \(templateName)"
        }
        
        if let description = job.processTemplate?.description {
            speechText += ". \(description)"
        }
        
        speechText += ". Status: \(job.statusEnum.displayName)"
        
        if let actions = job.actions {
            let completedCount = actions.filter { $0.isCompleted }.count
            speechText += ". Progress: \(completedCount) of \(actions.count) actions completed"
        }
        
        return speechText
    }
}

struct JobStatusBadge: View {
    let status: JobStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .ready: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
}

#Preview {
    JobsListView()
}

