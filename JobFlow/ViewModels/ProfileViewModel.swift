//
//  ProfileViewModel.swift
//  JobFlow
//
//  ViewModel for user profile management
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var userRole: UserRole?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Edit mode
    @Published var isEditing = false
    @Published var editedFullName = ""
    @Published var editedEmail = ""
    
    private let supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe authentication state
        supabaseService.$currentUser
            .sink { [weak self] user in
                if user != nil {
                    Task { await self?.loadProfile() }
                } else {
                    self?.profile = nil
                    self?.userRole = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load profile
            if let fetchedProfile = try await supabaseService.fetchCurrentProfile() {
                profile = fetchedProfile
                editedFullName = fetchedProfile.fullName ?? ""
                editedEmail = fetchedProfile.email ?? ""
            } else if let currentUser = supabaseService.currentUser {
                // Profile doesn't exist yet, show basic info from auth user
                errorMessage = "Profile not found in database. Please contact support or try signing out and back in."
                editedEmail = currentUser.email ?? ""
            }
            
            // Load user role (might not exist for new users)
            do {
                userRole = try await supabaseService.fetchUserRole()
            } catch {
                // User role might not exist yet
                print("User role not found: \(error)")
            }
            
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func startEditing() {
        guard let profile = profile else { return }
        editedFullName = profile.fullName ?? ""
        editedEmail = profile.email ?? ""
        isEditing = true
        errorMessage = nil
        successMessage = nil
    }
    
    func cancelEditing() {
        isEditing = false
        errorMessage = nil
        successMessage = nil
    }
    
    func saveProfile() async {
        guard let profile = profile, let profileId = profile.id else { 
            errorMessage = "Cannot save profile without ID"
            return 
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await supabaseService.updateProfile(
                userId: profileId,
                fullName: editedFullName.isEmpty ? nil : editedFullName,
                email: editedEmail
            )
            
            // Reload profile to get updated data
            await loadProfile()
            
            isEditing = false
            successMessage = "Profile updated successfully"
            
            // Clear success message after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                successMessage = nil
            }
            
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabaseService.signOut()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}

