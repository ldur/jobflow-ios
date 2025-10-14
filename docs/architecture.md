# JobFlow iOS Architecture

## Overview

The JobFlow iOS app is a job management application built with SwiftUI and Supabase backend. It follows a clean MVVM (Model-View-ViewModel) architecture with a centralized service layer for backend integration.

## Architecture Pattern

```
SupabaseService (Singleton) → ViewModels → SwiftUI Views
```

The app uses a unidirectional data flow where:
- **SupabaseService** handles all backend communication
- **ViewModels** manage business logic and UI state
- **Views** observe ViewModels and render UI

## Core Components

### 1. SupabaseService (Singleton)

**Location**: `JobFlow/Services/SupabaseService.swift`

The central service managing all Supabase interactions:

- **Authentication Management**: Handles user sessions, sign-in/sign-up, and token refresh
- **Data Operations**: Provides CRUD methods for all entities
- **State Publishing**: Uses `@Published` properties for reactive updates
- **Error Handling**: Graceful degradation with fallback strategies

**Key Features**:
- Singleton pattern ensures consistent state across the app
- Uses official Supabase Swift client library
- Automatic session management and persistence
- Comprehensive logging for debugging

### 2. Data Models

**Location**: `JobFlow/Models/Job.swift`

The app works with several key entities that mirror the Supabase database schema:

#### Core Entities

- **Job**: Main work items with status tracking and user assignments
  - Contains completion percentage calculation
  - Supports strict sequence enforcement
  - Links to ProcessTemplates and JobActionInstances

- **JobActionInstance**: Individual steps within jobs
  - Ordered by sequence for workflow management
  - Tracks completion status and notes
  - Supports bulk completion operations

- **Profile**: User profile information
  - Links to authentication users
  - Stores display names and contact info

- **ProcessTemplate**: Reusable job templates
  - Defines standard workflows
  - Used for job creation

- **ActionMedia**: Media attachments for actions
  - Supports images, videos, and audio
  - Provides type checking utilities

#### Model Features

- **Codable conformance** for JSON serialization
- **Identifiable** for SwiftUI list rendering
- **Hashable** for efficient collections
- **Custom CodingKeys** for snake_case to camelCase mapping
- **Computed properties** for business logic (e.g., completion status)

### 3. ViewModels

**Location**: `JobFlow/ViewModels/`

Each major screen has a dedicated ViewModel following the `@MainActor` pattern:

#### JobsViewModel
- Manages job list display and filtering
- Handles job loading and refresh operations
- Provides filtered views by status

#### JobDetailViewModel
- Manages individual job details and actions
- Handles action status updates and notes
- Enforces business rules (strict sequence, bulk completion)

#### AuthViewModel
- Manages authentication flow
- Handles sign-in, sign-up, and password reset
- Observes authentication state changes

#### ProfileViewModel
- Manages user profile display and editing
- Handles profile updates and role management
- Provides edit mode state management

**ViewModel Patterns**:
- Use `@Published` properties for reactive UI updates
- Implement async/await for backend operations
- Provide loading states and error handling
- Follow single responsibility principle

## Data Flow Patterns

### Fetching Data

```swift
// Example: Loading jobs with relations
let response: [Job] = try await client
    .from("jobs")
    .select("""
        *,
        process_templates(name, description),
        profiles(full_name),
        job_action_instances(*)
    """)
    .eq("assigned_to", value: userId)
    .order("created_at", ascending: false)
    .execute()
    .value
```

**Features**:
- **Relational Queries**: Fetches related data in single requests
- **Filtering**: User-specific data filtering
- **Ordering**: Consistent data sorting
- **Fallback Strategy**: Complex queries with simple fallbacks

### Updating Data

```swift
// Example: Updating job action with optimistic UI
try await supabaseService.updateJobAction(
    actionId: action.id,
    status: newStatus,
    completedAt: completedAt
)

// Update local state immediately
jobActions[index] = updatedAction
```

**Patterns**:
- **Optimistic Updates**: UI updates immediately
- **Targeted Updates**: Only modified fields sent
- **Batch Operations**: Multiple related updates in sequence
- **Error Recovery**: Rollback on failure

### Authentication Flow

```swift
// Reactive authentication state
supabaseService.$isAuthenticated
    .assign(to: &$isAuthenticated)
```

**Features**:
- **Session Persistence**: Automatic session restoration
- **Reactive Updates**: UI responds to auth state changes
- **Token Management**: Automatic refresh handling

## Business Logic Implementation

### Strict Sequence Enforcement

Jobs can enforce strict sequential completion of actions:

```swift
func canCompleteActionInSequence(_ action: JobActionInstance) -> Bool {
    guard let job = job, job.strictSequence == true else {
        return true
    }
    
    return !jobActions.contains { otherAction in
        otherAction.sequenceOrder < action.sequenceOrder && !otherAction.isCompleted
    }
}
```

### Bulk Completion

Users can complete a job at any action, auto-completing subsequent actions:

```swift
func completeJobFromAction(jobId: String, actionId: String, actionName: String, subsequentActions: [JobActionInstance]) async throws {
    // Update current action
    // Update all subsequent actions
    // Update job status to completed
}
```

### Progress Tracking

Jobs automatically calculate completion percentage:

```swift
var completionPercentage: Double {
    guard let actions = actions, !actions.isEmpty else { return 0 }
    let completedCount = actions.filter { $0.status == "completed" }.count
    return Double(completedCount) / Double(actions.count)
}
```

## Configuration Management

**Location**: `JobFlow/Utilities/Config.swift`

Centralized configuration with environment-based settings:

- **Environment Variables**: Reads from build settings
- **Fallback Values**: Hardcoded values for development
- **Build Configuration**: Different settings for Debug/Release

## Error Handling Strategy

### Service Level
- **Graceful Degradation**: Complex queries fall back to simple ones
- **Detailed Logging**: Comprehensive error tracking
- **User-Friendly Messages**: Localized error descriptions

### ViewModel Level
- **Loading States**: UI feedback during operations
- **Error Publishing**: Reactive error display
- **Recovery Actions**: Retry mechanisms where appropriate

### UI Level
- **Error Alerts**: User-facing error messages
- **Loading Indicators**: Progress feedback
- **Offline Handling**: Graceful offline behavior

## Key Architectural Benefits

1. **Separation of Concerns**: Clear boundaries between layers
2. **Testability**: ViewModels can be unit tested independently
3. **Reusability**: Service layer shared across ViewModels
4. **Maintainability**: Centralized backend logic
5. **Scalability**: Easy to add new features and entities
6. **Type Safety**: Strong typing throughout the stack
7. **Reactive UI**: Automatic updates via Combine framework

## Dependencies

- **Supabase Swift**: Official Supabase client library
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming framework
- **Foundation**: Core Swift functionality

## Future Considerations

- **Offline Support**: Local caching and sync strategies
- **Real-time Updates**: Supabase real-time subscriptions
- **Performance Optimization**: Query optimization and caching
- **Testing Strategy**: Unit and integration test coverage
- **Error Analytics**: Crash reporting and error tracking