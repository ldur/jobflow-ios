# JobFlow Xcode Project Setup

## ✅ Project Created!

Your JobFlow iOS project now has a **proper Xcode project file** (`JobFlow.xcodeproj`) that you can open directly in Xcode.

## 🚀 Opening the Project

```bash
cd ~/Documents/jobflow
open JobFlow.xcodeproj
```

Or simply **double-click `JobFlow.xcodeproj`** in Finder.

You should now see:
- ✅ **Proper Xcode project icon** (blue document with tools)
- ✅ **Project navigator** showing your source code files
- ✅ **Project settings** (select JobFlow target to see build settings, signing, etc.)
- ✅ **Build schemes** (JobFlow scheme in the top toolbar)
- ✅ **Swift Package dependencies** (automatically managed)

## 📁 Project Structure in Xcode

When opened, you'll see:
```
JobFlow (Project)
├── JobFlow (Target)
│   ├── KindredFlowGraphiOS/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Utilities/
│   │   └── Resources/
│   └── Dependencies (Swift Packages)
│       └── Supabase
└── Products
    └── JobFlow.app
```

## 🔧 Project Generation (Using XcodeGen)

This project uses **XcodeGen** to generate the Xcode project from `project.yml`. 

### Why XcodeGen?
- ✅ Keeps project configuration in version control (project.yml)
- ✅ Avoids merge conflicts in .xcodeproj files
- ✅ Easy to regenerate if project gets corrupted
- ✅ Consistent project structure across team

### Regenerating the Project

If you need to regenerate the project (e.g., after pulling changes to `project.yml`):

```bash
cd ~/Documents/jobflow
xcodegen generate
```

This will recreate `JobFlow.xcodeproj` based on the `project.yml` specification.

### Modifying Project Settings

To change project settings:

**Option 1: Edit in Xcode** (recommended for most settings)
- Open JobFlow.xcodeproj
- Select the JobFlow project in the navigator
- Modify settings in the project/target editor

**Option 2: Edit project.yml** (for structural changes)
- Edit `project.yml` with your changes
- Run `xcodegen generate` to apply changes
- Reopen the project in Xcode

## 🎯 Key Project Settings

### Target: JobFlow
- **Platform**: iOS 16.0+
- **Bundle ID**: com.jobflow.JobFlow
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI

### Build Configurations
- **Debug**: Development build with debugging enabled
- **Release**: Optimized production build

### Dependencies
- **Supabase** (2.0.0+): Backend integration

### Configuration Files
- **Config.xcconfig**: Environment variables (Supabase credentials)
  - Not committed to git (for security)
  - Create from `Config.xcconfig.example`

## 🔑 Required Setup

Before running the app:

1. **Create Config.xcconfig**:
   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

2. **Add your credentials** to `Config.xcconfig`:
   ```
   SUPABASE_URL = your_supabase_project_url
   SUPABASE_ANON_KEY = your_supabase_anon_key
   ```

3. **Select your development team**:
   - Open JobFlow.xcodeproj
   - Select JobFlow target
   - Go to Signing & Capabilities tab
   - Choose your Apple Developer team

## ▶️ Building and Running

1. Select a simulator or device from the device menu
2. Press ⌘+R to build and run
3. Or click the Play button in the toolbar

## 🛠 Common Tasks

### Clean Build
If you encounter build issues:
- Product → Clean Build Folder (⇧⌘K)

### Reset Package Dependencies
If packages aren't resolving:
- File → Packages → Reset Package Caches
- File → Packages → Resolve Package Versions

### View Build Settings
1. Select JobFlow project in navigator
2. Select JobFlow target
3. Go to Build Settings tab

### Edit App Info
Edit `KindredFlowGraphiOS/Resources/Info.plist` or modify in `project.yml`

## 📝 Files Explained

- **`JobFlow.xcodeproj/`**: The Xcode project (ignored in git, regenerated from project.yml)
- **`project.yml`**: XcodeGen configuration (committed to git)
- **`Package.swift`**: Swift Package Manager manifest (legacy, not used for app)
- **`Config.xcconfig`**: Your personal configuration (not committed)
- **`Config.xcconfig.example`**: Template for configuration

## 🎉 You're All Set!

Your JobFlow project is now a proper iOS app Xcode project ready for development!

For more help, see:
- **README.md** - Project overview
- **SETUP_GUIDE.md** - Detailed setup instructions
- **OPEN_IN_XCODE.md** - Additional Xcode guidance


