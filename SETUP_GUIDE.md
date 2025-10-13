# Kindred Flow Graph iOS - Setup Guide

This guide will walk you through setting up and running the iOS app for Kindred Flow Graph.

## Prerequisites

Before you begin, ensure you have:

- **macOS** with the latest version (Ventura 13.0 or later recommended)
- **Xcode 15.0** or later installed from the Mac App Store
- **iOS 16.0** or later device/simulator
- An active internet connection
- Access to your Supabase project credentials

## Step-by-Step Setup

### 1. Open Terminal and Navigate to the Project

```bash
cd /Users/lasse.durucz@m10s.io/Documents/kindred-flow-graph/KindredFlowGraphiOS
```

### 2. Create Xcode Project

Since this is a Swift package structure, you need to create an Xcode project. Here are two options:

#### Option A: Create Project in Xcode (Recommended)

1. Open **Xcode**
2. Select **File > New > Project**
3. Choose **iOS > App**
4. Fill in the details:
   - Product Name: `KindredFlowGraphiOS`
   - Team: Select your team
   - Organization Identifier: `com.kindred` (or your organization)
   - Interface: **SwiftUI**
   - Language: **Swift**
5. Save it in the `KindredFlowGraphiOS` directory
6. Delete the default `ContentView.swift` and `KindredFlowGraphiOSApp.swift` that Xcode creates
7. Add all the files from the project structure to your Xcode project:
   - Right-click on the project navigator
   - Select **Add Files to "KindredFlowGraphiOS"**
   - Select all folders (Models, Services, Views, ViewModels, Utilities, Resources)
   - Make sure "Copy items if needed" is checked
   - Click **Add**

#### Option B: Use Xcode from Command Line

```bash
# Generate Xcode project from Package.swift
swift package generate-xcodeproj
```

### 3. Add Swift Package Dependencies

1. In Xcode, select the project in the navigator
2. Select your app target
3. Go to the **General** tab
4. Scroll down to **Frameworks, Libraries, and Embedded Content**
5. Click the **+** button
6. Select **Add Package Dependency**
7. Enter the Supabase Swift package URL: `https://github.com/supabase/supabase-swift.git`
8. Click **Add Package**
9. Select **Supabase** from the product list
10. Click **Add Package**

### 4. Configure Supabase Credentials

1. Get your Supabase credentials:
   - Go to your [Supabase Dashboard](https://app.supabase.com)
   - Select your project
   - Go to **Settings > API**
   - Copy the **Project URL** and **anon/public** key

2. Create the configuration file:
   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

3. Edit `Config.xcconfig` with your credentials:
   ```
   SUPABASE_URL = https://your-actual-project-ref.supabase.co
   SUPABASE_ANON_KEY = your-actual-anon-key
   ```

4. Link the config file to your Xcode project:
   - Select the project in the navigator
   - Select your app target
   - Go to the **Build Settings** tab
   - Search for "configuration"
   - Under **Configuration** settings, add `Config.xcconfig` to your configurations

### 5. Set Environment Variables for Supabase

Since iOS apps can't directly use xcconfig files at runtime, you need to configure environment variables:

1. In Xcode, select your scheme (top bar, next to the device selector)
2. Click **Edit Scheme**
3. Select **Run** from the left sidebar
4. Go to the **Arguments** tab
5. Under **Environment Variables**, add:
   - Name: `SUPABASE_URL`, Value: `your-supabase-url`
   - Name: `SUPABASE_ANON_KEY`, Value: `your-supabase-anon-key`

### 6. Configure Signing

1. Select the project in the navigator
2. Select your app target
3. Go to the **Signing & Capabilities** tab
4. Select your **Team** (you may need to add an Apple ID first)
5. Xcode will automatically manage signing

### 7. Build and Run

1. Select a simulator or connected device from the device menu
2. Press **⌘ + R** or click the **Play** button
3. The app should build and launch

## Testing the App

### Test User Authentication

1. When the app launches, you'll see the login screen
2. If you have existing users in your Supabase auth, log in with those credentials
3. Or use the "Sign Up" option to create a new account

### Test Job Management

1. After logging in, you should see a list of jobs assigned to your user
2. Tap on a job to view its details
3. Check off actions as complete
4. Add notes to actions
5. View media associated with actions

## Troubleshooting

### "No such module 'Supabase'" Error

- Make sure you've added the Supabase Swift package dependency
- Clean the build folder: **Product > Clean Build Folder** (⇧⌘K)
- Reset package cache: **File > Packages > Reset Package Caches**

### Authentication Errors

- Verify your Supabase URL and anon key are correct
- Check that environment variables are set in the scheme
- Make sure your Supabase project has email authentication enabled
- Check the Xcode console for detailed error messages

### Jobs Not Loading

- Ensure you have jobs assigned to your user in the database
- Check that RLS (Row Level Security) policies allow the user to read jobs
- Use the Supabase dashboard to verify data exists
- Check network connectivity

### Build Errors

- Make sure you're using Xcode 15.0 or later
- Update to the latest version of the Supabase Swift SDK
- Clean build folder and derived data
- Restart Xcode

### Signing Issues

- Make sure you have a valid Apple Developer account
- Select the correct team in signing settings
- If using a free account, you may need to change the bundle identifier

## Additional Configuration

### Custom Bundle Identifier

If you need to change the bundle identifier:

1. Select the project in the navigator
2. Select your app target
3. Go to the **General** tab
4. Change the **Bundle Identifier**

### App Icons and Launch Screen

1. Add app icons:
   - Open `Assets.xcassets`
   - Select **AppIcon**
   - Drag and drop icons for various sizes

2. Customize launch screen:
   - Edit `LaunchScreen.storyboard` or create a SwiftUI launch screen

## Database Setup

Make sure your Supabase database has the correct schema. You can verify this by checking:

1. **Tables** exist:
   - `jobs`
   - `job_action_instances`
   - `process_templates`
   - `profiles`
   - `actions`
   - `action_media`
   - `user_roles`

2. **RLS Policies** are set up to allow users to:
   - Read their own jobs
   - Update job action instances for their jobs
   - Read related data (templates, actions, media)

3. **Sample Data** for testing:
   - Create at least one process template
   - Create at least one job assigned to your test user
   - Add some actions to the job

## Support

For issues or questions:

1. Check the main project README
2. Review Supabase documentation: https://supabase.com/docs
3. Check Supabase Swift SDK docs: https://github.com/supabase/supabase-swift
4. Create an issue in the repository

## Next Steps

Once your app is running:

1. Explore the job list and detail views
2. Test completing actions
3. Test the strict sequence mode
4. Try adding notes to actions
5. View media files
6. Test the "Complete Job Here" functionality

Happy coding! 🚀

