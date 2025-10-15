//
//  CalendarView.swift
//  JobFlow
//
//  Calendar view with daily, weekly, and monthly views for job scheduling
//

import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
    
    var icon: String {
        switch self {
        case .daily: return "calendar.day.timeline.left"
        case .weekly: return "calendar"
        case .monthly: return "calendar.badge.plus"
        }
    }
}

struct CalendarView: View {
    @StateObject private var viewModel = JobsViewModel()
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .monthly
    @State private var selectedJob: Job?
    @State private var selectedJobForCardView: Job?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar view mode picker
                calendarModePicker
                
                // Calendar content
                switch viewMode {
                case .daily:
                    DailyCalendarView(
                        selectedDate: $selectedDate,
                        jobs: viewModel.jobs,
                        onJobTap: { job in selectedJob = job },
                        onJobCardTap: { job in selectedJobForCardView = job }
                    )
                case .weekly:
                    WeeklyCalendarView(
                        selectedDate: $selectedDate,
                        jobs: viewModel.jobs,
                        onJobTap: { job in selectedJob = job },
                        onJobCardTap: { job in selectedJobForCardView = job }
                    )
                case .monthly:
                    MonthlyCalendarView(
                        selectedDate: $selectedDate,
                        jobs: viewModel.jobs,
                        onJobTap: { job in selectedJob = job },
                        onJobCardTap: { job in selectedJobForCardView = job }
                    )
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        withAnimation {
                            selectedDate = Date()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadJobs()
            }
            .sheet(item: $selectedJob) { job in
                NavigationView {
                    JobDetailView(jobId: job.id)
                }
            }
            .fullScreenCover(item: $selectedJobForCardView) { job in
                CardFlowView(jobId: job.id, jobName: job.name)
            }
        }
    }
    
    private var calendarModePicker: some View {
        HStack {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(viewMode == mode ? .white : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewMode == mode ? Color.blue : Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - Daily Calendar View
struct DailyCalendarView: View {
    @Binding var selectedDate: Date
    let jobs: [Job]
    let onJobTap: (Job) -> Void
    let onJobCardTap: (Job) -> Void
    
    private var dayJobs: [Job] {
        jobs.filter { job in
            guard job.scheduledDate != nil else { return false }
            return Calendar.current.isDate(job.scheduledDateAsDate, inSameDayAs: selectedDate)
        }
        .sorted { job1, job2 in
            return job1.scheduledDateAsDate < job2.scheduledDateAsDate
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Date navigation
            HStack {
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate, style: .date)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Jobs for the day
            ScrollView {
                LazyVStack(spacing: 12) {
                    if dayJobs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No jobs scheduled for this day")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(dayJobs) { job in
                            CalendarJobCard(
                                job: job,
                                onTap: { onJobTap(job) },
                                onCardTap: { onJobCardTap(job) }
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
    

}

// MARK: - Weekly Calendar View
struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    let jobs: [Job]
    let onJobTap: (Job) -> Void
    let onJobCardTap: (Job) -> Void
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Week navigation
            HStack {
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Week grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(weekDays, id: \.self) { day in
                        WeekDayView(
                            date: day,
                            jobs: jobsForDate(day),
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                            onDateTap: { selectedDate = day },
                            onJobTap: onJobTap,
                            onJobCardTap: onJobCardTap
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func jobsForDate(_ date: Date) -> [Job] {
        jobs.filter { job in
            guard job.scheduledDate != nil else { return false }
            return Calendar.current.isDate(job.scheduledDateAsDate, inSameDayAs: date)
        }
        .sorted { job1, job2 in
            return job1.scheduledDateAsDate < job2.scheduledDateAsDate
        }
    }
}

// MARK: - Monthly Calendar View
struct MonthlyCalendarView: View {
    @Binding var selectedDate: Date
    let jobs: [Job]
    let onJobTap: (Job) -> Void
    let onJobCardTap: (Job) -> Void
    
    private var monthDays: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let range = calendar.range(of: .day, in: .month, for: selectedDate) ?? 1..<32
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate, format: .dateTime.month(.wide).year())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Month grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(monthDays, id: \.self) { day in
                        MonthDayView(
                            date: day,
                            jobs: jobsForDate(day),
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                            onDateTap: { selectedDate = day },
                            onJobTap: onJobTap,
                            onJobCardTap: onJobCardTap
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func jobsForDate(_ date: Date) -> [Job] {
        jobs.filter { job in
            guard job.scheduledDate != nil else { return false }
            return Calendar.current.isDate(job.scheduledDateAsDate, inSameDayAs: date)
        }
        .sorted { job1, job2 in
            return job1.scheduledDateAsDate < job2.scheduledDateAsDate
        }
    }
}

#Preview {
    CalendarView()
}