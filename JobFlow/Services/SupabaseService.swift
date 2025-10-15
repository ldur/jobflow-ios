//
//  SupabaseService.swift
//  JobFlow
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
        // Initialize Supabase client with your credentials from Config
        // These values are loaded from Config.xcconfig
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL. Please ensure Config.xcconfig is properly set up with a valid SUPABASE_URL.")
        }
        
        let supabaseKey = Config.supabaseAnonKey
        
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
        print("🔐 Checking session...")
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
                print("🔐 Session valid. User ID: \(session.user.id)")
                print("🔐 User email: \(session.user.email ?? "no email")")
            }
        } catch {
            print("🔐 No valid session found: \(error)")
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
            data: fullName.map { ["full_name": AnyJSON.string($0)] }
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
            print("❌ No current user found")
            throw NSError(domain: "SupabaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        print("✅ Fetching jobs for user ID: \(userId)")
        
        do {
            // Try with embedded resources first
            let response: [Job] = try await client
                .from("jobs")
                .select("""
                    *,
                    process_templates(name, description),
                    profiles(full_name),
                    job_action_instances(*)
                """)
                .eq("assigned_to", value: userId)
                .execute()
                .value
            
            print("✅ Successfully fetched \(response.count) jobs with actions")
            for job in response {
                print("  - Job: \(job.name), Actions: \(job.actions?.count ?? 0)")
            }
            return response
        } catch {
            print("❌ Error fetching jobs with relations: \(error)")
            
            // Fallback: Try without relations
            print("🔄 Trying to fetch jobs without relations...")
            do {
                let response: [Job] = try await client
                    .from("jobs")
                    .select("*")
                    .eq("assigned_to", value: userId)
                    .execute()
                    .value
                
                print("✅ Successfully fetched \(response.count) jobs (without relations)")
                return response
            } catch {
                print("❌ Error fetching jobs without relations: \(error)")
                throw error
            }
        }
    }
    
    func fetchJobById(_ jobId: String) async throws -> Job {
        do {
            let response: [Job] = try await client
                .from("jobs")
                .select("""
                    *,
                    process_templates(name, description),
                    profiles(full_name),
                    job_action_instances(*)
                """)
                .eq("id", value: jobId)
                .execute()
                .value
            
            guard let job = response.first else {
                throw NSError(domain: "SupabaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Job not found"])
            }
            
            print("✅ Fetched job: \(job.name) with \(job.actions?.count ?? 0) actions")
            return job
        } catch {
            print("❌ Error fetching job by ID: \(error)")
            throw error
        }
    }
    
    func updateJobStatus(jobId: String, status: String, completedAt: String? = nil) async throws {
        var updateData: [String: AnyJSON] = ["status": .string(status)]
        if let completedAt = completedAt {
            updateData["completed_at"] = .string(completedAt)
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
        var updateData: [String: AnyJSON] = [:]
        
        if let status = status {
            updateData["status"] = .string(status)
        }
        if let notes = notes {
            updateData["notes"] = .string(notes)
        }
        if let completedAt = completedAt {
            updateData["completed_at"] = .string(completedAt)
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
        
        do {
            let response: [Profile] = try await client
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
                .value
            
            return response.first
        } catch {
            // If profile doesn't exist, return nil instead of throwing
            print("Profile fetch error: \(error)")
            return nil
        }
    }
    
    func updateProfile(userId: String, fullName: String?, email: String) async throws {
        var updateData: [String: AnyJSON] = ["email": .string(email)]
        
        if let fullName = fullName {
            updateData["full_name"] = .string(fullName)
        }
        
        try await client
            .from("profiles")
            .update(updateData)
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - User Roles
    
    func fetchUserRole() async throws -> UserRole? {
        guard let userId = currentUser?.id.uuidString else {
            return nil
        }
        
        do {
            let response: [UserRole] = try await client
                .from("user_roles")
                .select("*")
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return response.first
        } catch {
            // If user role doesn't exist, return nil instead of throwing
            print("User role fetch error: \(error)")
            return nil
        }
    }
}

