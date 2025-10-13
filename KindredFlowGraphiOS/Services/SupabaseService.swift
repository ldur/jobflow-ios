//
//  SupabaseService.swift
//  KindredFlowGraphiOS
//
//  Service layer for Supabase integration
//

import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        // Initialize Supabase client with your credentials
        // In production, store these in a secure configuration file
        guard let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
              let url = URL(string: supabaseURL) else {
            fatalError("Missing Supabase configuration. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.")
        }
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey
        )
        
        // Check for existing session
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Authentication
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        await MainActor.run {
            self.currentUser = session.user
            self.isAuthenticated = true
        }
    }
    
    func signUp(email: String, password: String, fullName: String?) async throws {
        let session = try await client.auth.signUp(
            email: email,
            password: password,
            data: fullName.map { ["full_name": $0] }
        )
        
        await MainActor.run {
            self.currentUser = session.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    // MARK: - Jobs
    
    func fetchJobs() async throws -> [Job] {
        guard let userId = currentUser?.id.uuidString else {
            throw NSError(domain: "SupabaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let response: [Job] = try await client
            .from("jobs")
            .select("""
                *,
                process_templates(name, description),
                profiles(full_name)
            """)
            .eq("assigned_to", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func fetchJobById(_ jobId: String) async throws -> Job {
        let response: Job = try await client
            .from("jobs")
            .select("""
                *,
                process_templates(name, description),
                profiles(full_name)
            """)
            .eq("id", value: jobId)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateJobStatus(jobId: String, status: String, completedAt: String? = nil) async throws {
        var updateData: [String: Any] = ["status": status]
        if let completedAt = completedAt {
            updateData["completed_at"] = completedAt
        }
        
        try await client
            .from("jobs")
            .update(updateData)
            .eq("id", value: jobId)
            .execute()
    }
    
    // MARK: - Job Action Instances
    
    func fetchJobActions(jobId: String) async throws -> [JobActionInstance] {
        let response: [JobActionInstance] = try await client
            .from("job_action_instances")
            .select("*")
            .eq("job_id", value: jobId)
            .order("sequence_order", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    func updateJobAction(actionId: String, status: String? = nil, notes: String? = nil, completedAt: String? = nil) async throws {
        var updateData: [String: Any] = [:]
        
        if let status = status {
            updateData["status"] = status
        }
        if let notes = notes {
            updateData["notes"] = notes
        }
        if let completedAt = completedAt {
            updateData["completed_at"] = completedAt
        }
        
        try await client
            .from("job_action_instances")
            .update(updateData)
            .eq("id", value: actionId)
            .execute()
    }
    
    func completeJobFromAction(jobId: String, actionId: String, actionName: String, subsequentActions: [JobActionInstance]) async throws {
        let currentTimestamp = ISO8601DateFormatter().string(from: Date())
        
        // Update current action
        try await updateJobAction(
            actionId: actionId,
            status: "completed",
            notes: "Job completed in this step by the user, all other Actions are autocompleted and marked",
            completedAt: currentTimestamp
        )
        
        // Update all subsequent actions
        for action in subsequentActions {
            if !action.isCompleted {
                try await updateJobAction(
                    actionId: action.id,
                    status: "completed",
                    notes: "Completed in Action: \(actionName)",
                    completedAt: currentTimestamp
                )
            }
        }
        
        // Update job status
        try await updateJobStatus(
            jobId: jobId,
            status: "completed",
            completedAt: currentTimestamp
        )
    }
    
    // MARK: - Action Media
    
    func fetchActionMedia(actionNames: [String]) async throws -> [String: [ActionMedia]] {
        // First, get action IDs from action names
        let actions: [Action] = try await client
            .from("actions")
            .select("id, name")
            .in("name", values: actionNames)
            .execute()
            .value
        
        guard !actions.isEmpty else {
            return [:]
        }
        
        let actionIds = actions.map { $0.id }
        
        // Fetch media for these actions
        let mediaList: [ActionMedia] = try await client
            .from("action_media")
            .select("*")
            .in("action_id", values: actionIds)
            .execute()
            .value
        
        // Map media to action names
        var mediaByActionName: [String: [ActionMedia]] = [:]
        for action in actions {
            let media = mediaList.filter { $0.actionId == action.id }
            if !media.isEmpty {
                mediaByActionName[action.name] = media
            }
        }
        
        return mediaByActionName
    }
    
    // MARK: - Profile
    
    func fetchCurrentProfile() async throws -> Profile? {
        guard let userId = currentUser?.id.uuidString else {
            return nil
        }
        
        let response: Profile = try await client
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - User Roles
    
    func fetchUserRole() async throws -> UserRole? {
        guard let userId = currentUser?.id.uuidString else {
            return nil
        }
        
        let response: UserRole = try await client
            .from("user_roles")
            .select("*")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        return response
    }
}

