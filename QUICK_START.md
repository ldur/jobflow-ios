# Quick Start Guide

Get up and running with Kindred Flow Graph iOS in minutes!

## 🚀 Fast Track Setup

### 1. Prerequisites Check
```bash
# Verify Xcode is installed
xcodebuild -version
```

You need:
- ✅ Xcode 15.0+
- ✅ macOS Ventura 13.0+
- ✅ Supabase account with project created

### 2. Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to: **Settings → API**
4. Copy:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

### 3. Configure the App

```bash
cd /Users/lasse.durucz@m10s.io/Documents/kindred-flow-graph/KindredFlowGraphiOS

# Copy configuration template
cp Config.xcconfig.example Config.xcconfig

# Edit with your credentials (use nano, vim, or open in any editor)
nano Config.xcconfig
```

Replace with your actual values:
```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = eyJhbGc...your-key
```

### 4. Run Setup Script

```bash
./create_xcode_project.sh
```

This will:
- Verify your setup
- Guide you through Xcode project creation
- Open Xcode when ready

### 5. Create Xcode Project

In Xcode:

1. **File → New → Project**
2. Choose **iOS → App**
3. Fill in:
   - Product Name: `KindredFlowGraphiOS`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. **Save in:** Select the `KindredFlowGraphiOS` folder
5. **Delete** auto-generated files:
   - `ContentView.swift`
   - `KindredFlowGraphiOSApp.swift`
6. **Add Files:**
   - Right-click project → **Add Files to "KindredFlowGraphiOS"**
   - Select `KindredFlowGraphiOS` folder
   - ✅ Create groups
   - Click **Add**

### 6. Add Supabase Package

1. Select project in navigator
2. Select app target
3. **General** tab → **Frameworks, Libraries, and Embedded Content**
4. Click **+** → **Add Package Dependency**
5. Enter: `https://github.com/supabase/supabase-swift.git`
6. Version: **2.0.0** (Up to Next Major)
7. Select **Supabase** product
8. Click **Add Package**

### 7. Configure Environment Variables

1. Click scheme (top bar, next to device selector)
2. **Edit Scheme...**
3. **Run** → **Arguments** tab
4. Under **Environment Variables**, click **+** twice and add:
   ```
   Name: SUPABASE_URL        Value: https://your-project.supabase.co
   Name: SUPABASE_ANON_KEY   Value: eyJhbGc...your-key
   ```

### 8. Build & Run! 🎉

1. Select a simulator (e.g., iPhone 15)
2. Press **⌘ + R** or click ▶️
3. App should launch!

## 🧪 Test the App

### First Login

1. Launch the app
2. Click **"Sign Up"**
3. Enter:
   - Email: `test@example.com`
   - Password: `password123`
   - Full Name: `Test User` (optional)
4. Click **Sign Up**

### View Jobs

After login, you'll see:
- List of jobs assigned to you
- Filter by status (Ready, In Progress, Completed)
- Pull to refresh

### Complete a Job

1. Tap on any job
2. View job details and actions
3. Check off actions as complete
4. Add notes to actions
5. View media files (if any)
6. Use "Complete Job Here" to finish early

## 🐛 Quick Troubleshooting

### "No such module 'Supabase'"
```
Solution:
- Product → Clean Build Folder (⇧⌘K)
- File → Packages → Reset Package Caches
- Build again (⌘B)
```

### "Failed to load jobs" / No data showing
```
Solution:
1. Check Supabase credentials in scheme environment variables
2. Verify database has sample data
3. Check RLS policies allow user access
```

### Authentication Fails
```
Solution:
1. Verify Supabase URL and key are correct
2. Check Supabase Auth is enabled (Settings → Authentication)
3. Check Xcode console for detailed error
```

### Signing Issues
```
Solution:
1. Select project → target → Signing & Capabilities
2. Select your Team
3. If no team, add Apple ID: Xcode → Settings → Accounts
```

## 📱 Features to Test

- ✅ User login/signup
- ✅ View list of jobs
- ✅ Filter jobs by status
- ✅ View job details
- ✅ Complete individual actions
- ✅ Add notes to actions
- ✅ View media attachments
- ✅ Complete job early (Complete Job Here)
- ✅ Strict sequence mode
- ✅ Pull to refresh
- ✅ Sign out

## 📚 Need More Help?

- **Detailed Setup:** See `SETUP_GUIDE.md`
- **Project Overview:** See `README.md`
- **Supabase Docs:** https://supabase.com/docs
- **Swift Package:** https://github.com/supabase/supabase-swift

## 🎯 Next Steps

1. Customize the UI to match your brand
2. Add push notifications for job updates
3. Implement offline mode with local caching
4. Add biometric authentication
5. Create admin features if needed

---

**Happy Building!** 🚀

If you run into issues, check the console logs in Xcode for detailed error messages.

