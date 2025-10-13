//
//  Job.swift
//  KindredFlowGraphiOS
//
//  Database models matching Supabase schema
//

import Foundation

// MARK: - Job Model
struct Job: Codable, Identifiable {
    let id: String
    let name: String
    let status: String?
    let assignedTo: String
    let templateId: String
    let scheduledDate: String?
    let completedAt: String?
    let createdAt: String?
    let strictSequence: Bool
    
    // Relations
    var processTemplate: ProcessTemplate?
    var profile: Profile?
    var actions: [JobActionInstance]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case assignedTo = "assigned_to"
        case templateId = "template_id"
        case scheduledDate = "scheduled_date"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case strictSequence = "strict_sequence"
        case processTemplate = "process_templates"
        case profile = "profiles"
        case actions
    }
    
    var statusEnum: JobStatus {
        JobStatus(rawValue: status ?? "ready") ?? .ready
    }
    
    var completionPercentage: Double {
        guard let actions = actions, !actions.isEmpty else { return 0 }
        let completedCount = actions.filter { $0.status == "completed" }.count
        return Double(completedCount) / Double(actions.count)
    }
}

enum JobStatus: String, Codable, CaseIterable {
    case ready = "ready"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .ready: return "Ready"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .ready: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .cancelled: return "gray"
        }
    }
}

// MARK: - Job Action Instance Model
struct JobActionInstance: Codable, Identifiable {
    let id: String
    let jobId: String
    let name: String
    let description: String?
    let sequenceOrder: Int
    let status: String?
    let notes: String?
    let completedAt: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobId = "job_id"
        case name
        case description
        case sequenceOrder = "sequence_order"
        case status
        case notes
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
    
    var isCompleted: Bool {
        status == "completed"
    }
}

// MARK: - Process Template Model
struct ProcessTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let createdBy: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Profile Model
struct Profile: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Action Model
struct Action: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let mediaType: String?
    let autoInject: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case mediaType = "media_type"
        case autoInject = "auto_inject"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Action Media Model
struct ActionMedia: Codable, Identifiable {
    let id: String
    let actionId: String
    let mediaUrl: String
    let mediaType: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case actionId = "action_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case createdAt = "created_at"
    }
    
    var isImage: Bool {
        mediaType.lowercased().contains("image")
    }
    
    var isVideo: Bool {
        mediaType.lowercased().contains("video")
    }
    
    var isAudio: Bool {
        mediaType.lowercased().contains("audio")
    }
}

// MARK: - User Role Model
struct UserRole: Codable, Identifiable {
    let id: String
    let userId: String
    let role: AppRole
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case role
        case createdAt = "created_at"
    }
}

enum AppRole: String, Codable {
    case admin = "admin"
    case user = "user"
}

