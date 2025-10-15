//
//  CalendarComponents.swift
//  JobFlow
//
//  Supporting components for calendar views
//

import SwiftUI

// MARK: - Calendar Job Card
struct CalendarJobCard: View {
    let job: Job
    let onTap: () -> Void
    let onCardTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(job.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Spacer()
                
                JobStatusBadge(status: job.statusEnum)
            }
            
            if let templateName = job.processTemplate?.name {
                Text(templateName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Progress
            if let actions = job.actions {
                let completedCount = actions.filter { $0.isCompleted }.count
                HStack {
                    ProgressView(value: job.completionPercentage)
                        .tint(progressColor(for: job.statusEnum))
                    
                    Text("\(completedCount)/\(actions.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.caption)
                        Text("Details")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                Button(action: onCardTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.stack")
                            .font(.caption)
                        Text("Start")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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

// MARK: - Week Day View
struct WeekDayView: View {
    let date: Date
    let jobs: [Job]
    let isSelected: Bool
    let onDateTap: () -> Void
    let onJobTap: (Job) -> Void
    let onJobCardTap: (Job) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Day header
            Button(action: onDateTap) {
                VStack(spacing: 4) {
                    Text(date, format: .dateTime.weekday(.abbreviated))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(date, format: .dateTime.day())
                        .font(.subheadline)
                        .fontWeight(isSelected ? .bold : .medium)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Jobs for this day
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(jobs.prefix(3)) { job in
                        WeekJobItem(
                            job: job,
                            onTap: { onJobTap(job) },
                            onCardTap: { onJobCardTap(job) }
                        )
                    }
                    
                    if jobs.count > 3 {
                        Text("+\(jobs.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Week Job Item
struct WeekJobItem: View {
    let job: Job
    let onTap: () -> Void
    let onCardTap: () -> Void
    
    var body: some View {
        Menu {
            Button("View Details", action: onTap)
            Button("Start Job", action: onCardTap)
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor(for: job.statusEnum))
                    .frame(width: 6, height: 6)
                
                Text(job.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
            .cornerRadius(4)
        }
    }
    
    private func statusColor(for status: JobStatus) -> Color {
        switch status {
        case .ready: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
}

// MARK: - Month Day View
struct MonthDayView: View {
    let date: Date
    let jobs: [Job]
    let isSelected: Bool
    let onDateTap: () -> Void
    let onJobTap: (Job) -> Void
    let onJobCardTap: (Job) -> Void
    
    var body: some View {
        Button(action: onDateTap) {
            VStack(spacing: 4) {
                Text(date, format: .dateTime.day())
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Job indicators
                HStack(spacing: 2) {
                    ForEach(jobs.prefix(3)) { job in
                        Circle()
                            .fill(statusColor(for: job.statusEnum))
                            .frame(width: 4, height: 4)
                    }
                    
                    if jobs.count > 3 {
                        Text("+")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 8)
            }
            .frame(width: 40, height: 50)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if !jobs.isEmpty {
                ForEach(jobs.prefix(5)) { job in
                    Menu(job.name) {
                        Button("View Details") { onJobTap(job) }
                        Button("Start Job") { onJobCardTap(job) }
                    }
                }
                
                if jobs.count > 5 {
                    Text("And \(jobs.count - 5) more jobs...")
                }
            }
        }
    }
    
    private func statusColor(for status: JobStatus) -> Color {
        switch status {
        case .ready: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
}

#Preview {
    VStack {
        CalendarJobCard(
            job: Job(
                id: "1",
                name: "Sample Job",
                status: "ready",
                assignedTo: "user1",
                templateId: "template1",
                scheduledDate: "2024-01-15T10:00:00Z",
                completedAt: nil,
                createdAt: "2024-01-01T00:00:00Z",
                strictSequence: false
            ),
            onTap: {},
            onCardTap: {}
        )
        .padding()
    }
}