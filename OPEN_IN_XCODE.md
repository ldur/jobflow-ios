# Opening JobFlow in Xcode

This guide will help you open the JobFlow iOS project in Xcode.

## Quick Start

### Open the Xcode Project (Recommended)

Simply double-click `JobFlow.xcodeproj` in Finder or run:

```bash
cd ~/Documents/jobflow
open JobFlow.xcodeproj
```

Xcode will automatically open the project and resolve all Swift Package dependencies.

### Using the Setup Script (Alternative)

For a guided setup with configuration help:

```bash
cd ~/Documents/jobflow
./create_xcode_project.sh
```

This script will:
- Check if you have the required `Config.xcconfig` file
- Guide you through adding Supabase credentials
- Open the project in Xcode

## Configuration

Before running the app, you need to configure your Supabase credentials:

1. Copy the example config:
   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

2. Edit `Config.xcconfig` and add your credentials:
   ```
   SUPABASE_URL = your_supabase_project_url
   SUPABASE_ANON_KEY = your_supabase_anon_key
   ```

3. Get your credentials from: [Supabase Dashboard](https://app.supabase.com) → Your Project → Settings → API

## First Run

1. **Select a target device**: Choose an iPhone simulator from the dropdown
2. **Select your team**: Go to Signing & Capabilities and select your development team
3. **Build and run**: Press ⌘+R

## Troubleshooting

### Dependencies Not Resolving
- File → Packages → Resolve Package Versions
- File → Packages → Reset Package Caches

### Build Errors
- Product → Clean Build Folder (⇧⌘K)
- Close and reopen Xcode
- Delete the `.build` folder and reopen

### Code Signing Issues
- Ensure you have selected a valid development team
- You may need to change the bundle identifier to something unique

## Project Structure

Once opened, you'll see:
- **KindredFlowGraphiOS**: Main source code
  - Models: Data models
  - Services: API and business logic
  - Views: SwiftUI UI components
  - ViewModels: State management
  - Utilities: Helper functions
- **Dependencies**: Swift Package dependencies (auto-managed)

## Need Help?

See these files for more information:
- `README.md` - General project overview
- `SETUP_GUIDE.md` - Detailed setup instructions
- `QUICK_START.md` - Quick reference guide
- `START_HERE.md` - Getting started guide

