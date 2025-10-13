//
//  JobsListView.swift
//  KindredFlowGraphiOS
//
//  List view for all jobs assigned to user
//

import SwiftUI

struct JobsListView: View {
    @StateObject private var viewModel = JobsViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
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
                            Label("All Jobs", systemImage: viewModel.selectedStatus == nil ? "checkmark" : "")
                        }
                        
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            Button {
                                viewModel.selectedStatus = status
                            } label: {
                                Label(status.displayName, systemImage: viewModel.selectedStatus == status ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshJobs()
            }
            .task {
                await viewModel.loadJobs()
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
                        NavigationLink(destination: JobDetailView(jobId: job.id)) {
                            JobRowView(job: job)
                        }
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
                                NavigationLink(destination: JobDetailView(jobId: job.id)) {
                                    JobRowView(job: job)
                                }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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

