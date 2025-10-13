# Kindred Flow Graph iOS App

A native iOS application for managing and executing workflow jobs, built with SwiftUI and Supabase.

## Features

- **User Authentication**: Secure login with email/password using Supabase Auth
- **Job Management**: View and manage assigned workflow jobs
- **Job Execution**: Complete job actions with notes and media viewing
- **Real-time Updates**: Automatic synchronization with backend
- **Offline Support**: View cached job data when offline

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

### 1. Install Dependencies

This project uses Swift Package Manager. Dependencies will be automatically resolved when you open the project in Xcode.

Required packages:
- [Supabase Swift](https://github.com/supabase/supabase-swift) - For backend integration

### 2. Configure Environment

1. Create a `Config.xcconfig` file in the project root (see `Config.xcconfig.example`)
2. Add your Supabase credentials:

```
SUPABASE_URL = your_supabase_project_url
SUPABASE_ANON_KEY = your_supabase_anon_key
```

**Important**: Add `Config.xcconfig` to your `.gitignore` to keep credentials secure.

### 3. Open in Xcode

1. Open `KindredFlowGraphiOS.xcodeproj` in Xcode
2. Select your development team in the Signing & Capabilities tab
3. Build and run the project

## Project Structure

```
KindredFlowGraphiOS/
├── Models/              # Data models matching Supabase schema
├── Services/            # API and business logic services
├── Views/              # SwiftUI views
├── ViewModels/         # View models for MVVM pattern
├── Utilities/          # Helper utilities and extensions
└── Resources/          # Assets, configs, and resources
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Codable structs representing database tables
- **Services**: Handle API calls and data persistence
- **ViewModels**: Business logic and state management
- **Views**: SwiftUI views for UI rendering

## Key Features Implementation

### Authentication
- Email/password login via Supabase Auth
- Persistent sessions with automatic token refresh
- Secure credential storage using Keychain

### Job Management
- Fetch jobs assigned to the current user
- Filter jobs by status (ready, in_progress, completed)
- Real-time job status updates

### Job Execution
- View job details and action steps
- Complete actions with checkboxes
- Add notes to individual actions
- View associated media (images, videos, documents)
- Strict sequence mode enforcement
- "Complete Job Here" functionality

## API Integration

The app connects to your existing Supabase backend. Key endpoints:

- Authentication: Supabase Auth API
- Jobs: `jobs` table with relations to `process_templates` and `profiles`
- Actions: `job_action_instances` table
- Media: `action_media` table

## Security

- Supabase credentials stored in configuration file (not committed to git)
- Row Level Security (RLS) enforced by Supabase backend
- Secure token storage using iOS Keychain
- HTTPS-only network communication

## Testing

Run tests with:
```bash
xcodebuild test -scheme KindredFlowGraphiOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting

### Build Errors
- Ensure all Swift Package dependencies are resolved
- Clean build folder: Product → Clean Build Folder
- Reset package cache: File → Packages → Reset Package Caches

### Authentication Issues
- Verify Supabase URL and Anon Key are correct
- Check Supabase Auth settings (email confirmation, etc.)
- Ensure RLS policies allow user access

### Data Not Loading
- Check network connectivity
- Verify Supabase RLS policies
- Review Xcode console for error messages

## Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Submit a pull request

## License

[Add your license here]

## Support

For issues or questions, please create an issue in the repository.

