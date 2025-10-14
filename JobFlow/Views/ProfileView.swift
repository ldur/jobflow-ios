//
//  ProfileView.swift
//  JobFlow
//
//  User profile view with edit capabilities
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView("Loading profile...")
                } else if let profile = viewModel.profile {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            profileHeader(profile: profile)
                            
                            // User Info Section
                            if viewModel.isEditing {
                                editSection
                            } else {
                                infoSection(profile: profile)
                            }
                            
                            // Role Badge
                            if let userRole = viewModel.userRole {
                                roleBadge(role: userRole.role)
                            }
                            
                            // Error/Success Messages
                            if let errorMessage = viewModel.errorMessage {
                                MessageBanner(message: errorMessage, type: .error)
                            }
                            
                            if let successMessage = viewModel.successMessage {
                                MessageBanner(message: successMessage, type: .success)
                            }
                            
                            // Sign Out Button
                            if !viewModel.isEditing {
                                signOutButton
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Profile Not Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Unable to load your profile information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !viewModel.isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            viewModel.startEditing()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeader(profile: Profile) -> some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(initials(from: profile.fullName ?? profile.email ?? "User"))
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Name
            Text(profile.fullName ?? "User")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.top)
    }
    
    // MARK: - Info Section
    
    private func infoSection(profile: Profile) -> some View {
        VStack(spacing: 16) {
            InfoRow(label: "Full Name", value: profile.fullName ?? "Not set", icon: "person.fill")
            InfoRow(label: "Email", value: profile.email ?? "Not set", icon: "envelope.fill")
            
            if let createdAt = profile.createdAt {
                InfoRow(label: "Member Since", value: formatDate(createdAt), icon: "calendar")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Edit Section
    
    private var editSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                TextField("Enter your full name", text: $viewModel.editedFullName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocapitalization(.words)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                TextField("Enter your email", text: $viewModel.editedEmail)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.cancelEditing()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                Button {
                    Task {
                        await viewModel.saveProfile()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading || viewModel.editedEmail.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Role Badge
    
    private func roleBadge(role: AppRole) -> some View {
        HStack {
            Image(systemName: role == .admin ? "star.fill" : "person.fill")
            Text(role.rawValue.capitalized)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(role == .admin ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.2))
        .foregroundColor(role == .admin ? .orange : .blue)
        .cornerRadius(20)
    }
    
    // MARK: - Sign Out Button
    
    private var signOutButton: some View {
        Button {
            Task {
                await viewModel.signOut()
                dismiss()
            }
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Functions
    
    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "U"
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Try ISO8601 format first
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
        
        // Try alternative formats
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Try common Supabase formats
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "dd.MM.yyyy"
                return dateFormatter.string(from: date)
            }
        }
        
        // If all else fails, return original string
        return dateString
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

// MARK: - Message Banner Component

struct MessageBanner: View {
    let message: String
    let type: MessageType
    
    enum MessageType {
        case error, success
        
        var color: Color {
            switch self {
            case .error: return .red
            case .success: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "exclamationmark.circle"
            case .success: return "checkmark.circle"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .foregroundColor(type.color)
        .cornerRadius(10)
    }
}

#Preview {
    ProfileView()
}

