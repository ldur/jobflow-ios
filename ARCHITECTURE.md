# Kindred Flow Graph iOS - Architecture

## Overview

This document describes the architecture, design patterns, and structure of the Kindred Flow Graph iOS application.

## Architecture Pattern: MVVM

The app follows the **Model-View-ViewModel (MVVM)** architecture pattern, which provides:

- ✅ Clear separation of concerns
- ✅ Testable business logic
- ✅ Reactive data binding with Combine
- ✅ Maintainable codebase

```
┌──────────────────────────────────────────────┐
│                    View                      │
│              (SwiftUI Views)                 │
│  LoginView, JobsListView, JobDetailView     │
└────────────┬─────────────────────────────────┘
             │ Observes & Binds
             ▼
┌──────────────────────────────────────────────┐
│                 ViewModel                     │
│          (@Published Properties)             │
│   AuthViewModel, JobsViewModel, etc.        │
└────────────┬─────────────────────────────────┘
             │ Uses
             ▼
┌──────────────────────────────────────────────┐
│                  Service                      │
│            (Business Logic)                   │
│            SupabaseService                    │
└────────────┬─────────────────────────────────┘
             │ Operates on
             ▼
┌──────────────────────────────────────────────┐
│                   Model                       │
│              (Data Structures)                │
│    Job, Action, Profile, etc.                │
└──────────────────────────────────────────────┘
```

## Project Structure

```
KindredFlowGraphiOS/
├── KindredFlowGraphiOS/
│   ├── Models/                  # Data models
│   │   └── Job.swift           # All database models
│   │
│   ├── Services/               # Business logic & API
│   │   └── SupabaseService.swift
│   │
│   ├── ViewModels/             # View state & logic
│   │   ├── AuthViewModel.swift
│   │   ├── JobsViewModel.swift
│   │   └── JobDetailViewModel.swift
│   │
│   ├── Views/                  # UI components
│   │   ├── LoginView.swift
│   │   ├── JobsListView.swift
│   │   └── JobDetailView.swift
│   │
│   ├── Utilities/              # Helpers & extensions
│   │   └── Extensions.swift
│   │
│   ├── Resources/              # Assets & configs
│   │   └── Info.plist
│   │
│   └── KindredFlowGraphiOSApp.swift  # App entry point
│
├── Config.xcconfig             # Environment config (gitignored)
├── Package.swift               # Swift Package Manager
└── README.md                   # Documentation
```

## Layer Responsibilities

### 1. Models Layer

**Purpose:** Define data structures matching the Supabase database schema

**Files:**
- `Job.swift` - Contains all model definitions

**Models:**
- `Job` - Main job entity with relations
- `JobActionInstance` - Individual action within a job
- `ProcessTemplate` - Job template/blueprint
- `Profile` - User profile
- `Action` - Action definition
- `ActionMedia` - Media files attached to actions
- `UserRole` - User role (admin/user)

**Key Features:**
- Codable for JSON serialization
- Identifiable for SwiftUI lists
- Computed properties for derived data
- Enums for type safety

**Example:**
```swift
struct Job: Codable, Identifiable {
    let id: String
    let name: String
    let status: String?
    var processTemplate: ProcessTemplate?
    var actions: [JobActionInstance]?
    
    var completionPercentage: Double {
        // Computed property logic
    }
}
```

### 2. Services Layer

**Purpose:** Handle all backend communication and business logic

**Files:**
- `SupabaseService.swift` - Singleton service for Supabase integration

**Responsibilities:**
- Authentication (sign in, sign up, sign out)
- CRUD operations on database
- Data fetching and caching
- Error handling
- Session management

**Key Features:**
- Singleton pattern for shared state
- Async/await for asynchronous operations
- ObservableObject for reactive updates
- Centralized error handling

**Example:**
```swift
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    func signIn(email: String, password: String) async throws { }
    func fetchJobs() async throws -> [Job] { }
}
```

### 3. ViewModels Layer

**Purpose:** Manage view state and handle user interactions

**Files:**
- `AuthViewModel.swift` - Authentication state
- `JobsViewModel.swift` - Jobs list state
- `JobDetailViewModel.swift` - Job detail state

**Responsibilities:**
- Hold view state (@Published properties)
- Handle user actions
- Coordinate with services
- Transform data for views
- Manage loading/error states

**Key Features:**
- @MainActor for UI updates
- ObservableObject for reactive binding
- Input validation
- Error message formatting

**Example:**
```swift
@MainActor
class JobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadJobs() async {
        isLoading = true
        // Fetch from service
        isLoading = false
    }
}
```

### 4. Views Layer

**Purpose:** Define the user interface with SwiftUI

**Files:**
- `LoginView.swift` - Authentication UI
- `JobsListView.swift` - Jobs list with filtering
- `JobDetailView.swift` - Job details with actions

**Responsibilities:**
- Render UI components
- Bind to ViewModel data
- Handle user gestures
- Navigation
- Visual styling

**Key Features:**
- Declarative SwiftUI syntax
- @StateObject for ViewModel ownership
- Navigation and routing
- Responsive layouts
- Custom components

**Example:**
```swift
struct JobsListView: View {
    @StateObject private var viewModel = JobsViewModel()
    
    var body: some View {
        List(viewModel.jobs) { job in
            JobRowView(job: job)
        }
        .task {
            await viewModel.loadJobs()
        }
    }
}
```

## Data Flow

### 1. User Action Flow
```
User Interaction
    ↓
View captures event
    ↓
View calls ViewModel method
    ↓
ViewModel updates @Published state
    ↓
View automatically re-renders
```

### 2. Data Fetch Flow
```
View appears
    ↓
ViewModel calls Service
    ↓
Service calls Supabase API
    ↓
Service returns data
    ↓
ViewModel updates @Published properties
    ↓
View observes changes and updates UI
```

### 3. Error Handling Flow
```
Error occurs in Service
    ↓
Service throws error
    ↓
ViewModel catches error
    ↓
ViewModel sets errorMessage
    ↓
View displays alert/message
```

## State Management

### Published Properties

Used for reactive state:
```swift
@Published var jobs: [Job] = []
@Published var isLoading = false
@Published var errorMessage: String?
```

### StateObject vs ObservedObject

- **@StateObject**: Used when view owns the ViewModel
  ```swift
  @StateObject private var viewModel = JobsViewModel()
  ```

- **@ObservedObject**: Used when ViewModel is passed from parent
  ```swift
  @ObservedObject var viewModel: JobDetailViewModel
  ```

### EnvironmentObject

Used for app-wide singletons:
```swift
@EnvironmentObject var supabaseService: SupabaseService
```

## Navigation

### Navigation Patterns

1. **NavigationView** - Root navigation container
2. **NavigationLink** - Push navigation
3. **Sheet** - Modal presentation
4. **Alert** - Error/confirmation dialogs

### Example Flow
```
LoginView
    ↓ (authenticated)
JobsListView
    ↓ (tap job)
JobDetailView
    ↓ (view media)
MediaViewerView (sheet)
```

## Networking

### Supabase Integration

**Client Setup:**
```swift
let client = SupabaseClient(
    supabaseURL: URL(string: supabaseURL)!,
    supabaseKey: supabaseKey
)
```

**Query Pattern:**
```swift
let response: [Job] = try await client
    .from("jobs")
    .select("*, process_templates(*)")
    .eq("assigned_to", value: userId)
    .execute()
    .value
```

**Update Pattern:**
```swift
try await client
    .from("jobs")
    .update(["status": "completed"])
    .eq("id", value: jobId)
    .execute()
```

## Authentication

### Session Management

1. Session stored automatically by Supabase SDK
2. Auto-refresh on app launch
3. Token stored securely
4. Observable authentication state

### Auth Flow
```
App Launch
    ↓
Check session
    ↓
    ├─ Valid → JobsListView
    └─ Invalid → LoginView
           ↓
       Sign In/Up
           ↓
    Session created
           ↓
    Navigate to JobsListView
```

## Error Handling

### Strategy

1. **Service Level**: Catch and throw typed errors
2. **ViewModel Level**: Catch, format, and expose to view
3. **View Level**: Display user-friendly messages

### Example
```swift
// Service
func fetchJobs() async throws -> [Job] {
    // Throws on error
}

// ViewModel
func loadJobs() async {
    do {
        jobs = try await service.fetchJobs()
    } catch {
        errorMessage = error.localizedDescription
    }
}

// View
.alert("Error", isPresented: $showError) {
    Text(viewModel.errorMessage)
}
```

## Performance Optimizations

### 1. Async/Await
- Non-blocking UI operations
- Clean asynchronous code

### 2. Lazy Loading
- Load data on-demand
- Paginate large lists

### 3. Caching
- Store fetched data in memory
- Reduce unnecessary network calls

### 4. Image Loading
- AsyncImage for efficient loading
- Lazy loading in scrolling lists

## Security

### Best Practices

1. **Credentials**: Environment variables only
2. **Row Level Security**: Enforced on backend
3. **HTTPS Only**: All network calls secure
4. **Token Storage**: Automatic by Supabase SDK
5. **Input Validation**: Always validate user input

## Testing Strategy

### Unit Tests
- Test ViewModels in isolation
- Mock SupabaseService
- Test business logic

### Integration Tests
- Test Service with real API (staging)
- Test complete flows

### UI Tests
- Test user workflows
- Test navigation
- Test error states

## Future Enhancements

### Planned Features

1. **Offline Mode**
   - Local database (Core Data / Realm)
   - Sync when online

2. **Push Notifications**
   - Job assignments
   - Action reminders
   - Status updates

3. **Real-time Updates**
   - Supabase Realtime subscriptions
   - Live job status changes

4. **Advanced Features**
   - Biometric authentication
   - Camera integration for media
   - Dark mode
   - iPad support
   - Widgets

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [Swift Async/Await](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

**Last Updated:** 2025-10-13

