//
//  JobsListView.swift
//  JobFlow
//
//  List view for all jobs assigned to user
//

import SwiftUI

struct JobsListView: View {
    @StateObject private var viewModel = JobsViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingProfile = false
    @State private var selectedJob: Job?
    @State private var selectedJobForCardView: Job?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    ProgressView("Loading jobs...")
                } else if viewModel.jobs.isEmpty {
                    emptyStateView
                } else {
                    jobsListView
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
                    Button {
                        showingProfile = true
                    } label: {
                        Label("Profile", systemImage: "person.circle")
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(job.name)
                    .font(.headline)
                
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

