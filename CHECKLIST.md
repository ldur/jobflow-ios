# iOS App Setup Checklist ✅

Use this checklist to track your progress setting up the Kindred Flow Graph iOS app.

## 📋 Pre-Setup

- [ ] Xcode 15.0+ installed
- [ ] macOS Ventura 13.0+ running
- [ ] Apple Developer account (free or paid)
- [ ] Supabase project created and running
- [ ] Backend has sample data for testing

## 🔐 Supabase Configuration

- [ ] Logged into Supabase Dashboard
- [ ] Located Project URL (Settings → API)
- [ ] Copied anon/public key (Settings → API)
- [ ] Verified database schema matches project (see types.ts)
- [ ] Confirmed RLS policies allow user access
- [ ] Created test user account (if needed)
- [ ] Created test job assigned to user (if needed)

## 📝 Project Configuration

- [ ] Opened Terminal
- [ ] Navigated to KindredFlowGraphiOS directory
- [ ] Ran `./create_xcode_project.sh`
- [ ] Created `Config.xcconfig` from example
- [ ] Added Supabase URL to Config.xcconfig
- [ ] Added Supabase anon key to Config.xcconfig
- [ ] Verified Config.xcconfig is in .gitignore

## 🏗️ Xcode Project Setup

### Create Project
- [ ] Opened Xcode
- [ ] Created new iOS App project
- [ ] Named it: KindredFlowGraphiOS
- [ ] Selected SwiftUI interface
- [ ] Selected Swift language
- [ ] Saved in KindredFlowGraphiOS directory

### Add Files
- [ ] Deleted auto-generated ContentView.swift
- [ ] Deleted auto-generated KindredFlowGraphiOSApp.swift
- [ ] Added KindredFlowGraphiOS folder to project
- [ ] Verified all folders are visible in navigator:
  - [ ] Models
  - [ ] Services
  - [ ] ViewModels
  - [ ] Views
  - [ ] Utilities
  - [ ] Resources

### Add Dependencies
- [ ] Added Supabase Swift package
- [ ] Package URL: https://github.com/supabase/supabase-swift.git
- [ ] Version: 2.0.0 or later
- [ ] Selected Supabase product
- [ ] Package resolved successfully

### Configure Signing
- [ ] Selected project in navigator
- [ ] Selected app target
- [ ] Opened Signing & Capabilities tab
- [ ] Selected Team (or added Apple ID)
- [ ] Automatic signing enabled
- [ ] Bundle identifier is unique

### Environment Variables
- [ ] Clicked scheme dropdown (top bar)
- [ ] Selected "Edit Scheme..."
- [ ] Selected Run → Arguments tab
- [ ] Added SUPABASE_URL variable
- [ ] Added SUPABASE_ANON_KEY variable
- [ ] Values match Config.xcconfig

## 🔨 Build & Test

### Initial Build
- [ ] Selected simulator (iPhone 15 recommended)
- [ ] Pressed ⌘+B (Build)
- [ ] Build succeeded with no errors
- [ ] All Swift packages resolved

### First Run
- [ ] Pressed ⌘+R (Build and Run)
- [ ] App launched successfully
- [ ] Login screen appeared
- [ ] UI looks correct (no broken layouts)

## 🧪 Feature Testing

### Authentication
- [ ] Clicked "Sign Up" tab
- [ ] Entered test email
- [ ] Entered password (6+ chars)
- [ ] Entered full name (optional)
- [ ] Clicked "Sign Up" button
- [ ] Account created successfully
- [ ] Navigated to jobs list

OR

- [ ] Entered existing user email
- [ ] Entered password
- [ ] Clicked "Sign In" button
- [ ] Signed in successfully
- [ ] Navigated to jobs list

### Jobs List
- [ ] Jobs list displayed
- [ ] Jobs show correct information
- [ ] Status badges visible
- [ ] Progress bars visible
- [ ] Can pull to refresh
- [ ] Filter menu works
- [ ] Can tap on a job

### Job Detail
- [ ] Job detail view opened
- [ ] Job name and template shown
- [ ] Actions list displayed
- [ ] Step numbers visible
- [ ] Can check/uncheck actions
- [ ] Progress updates correctly

### Action Features
- [ ] Can add notes to action
- [ ] Notes save automatically
- [ ] Media thumbnails visible (if any)
- [ ] Can tap media to view full screen
- [ ] Media viewer opens correctly
- [ ] Can close media viewer

### Job Completion
- [ ] Checked off an action
- [ ] Action marked as completed
- [ ] Timestamp displayed
- [ ] Progress bar updated
- [ ] Checked off all actions
- [ ] Job status changed to "completed"

### Advanced Features
- [ ] Tested strict sequence mode (if applicable)
- [ ] Previous actions must complete first
- [ ] Lock icon shows on disabled actions
- [ ] "Complete Job Here" button visible
- [ ] Tapped "Complete Job Here"
- [ ] Confirmation alert appeared
- [ ] Confirmed action
- [ ] Remaining actions completed
- [ ] Job marked as completed

### Sign Out
- [ ] Clicked sign out button
- [ ] Returned to login screen
- [ ] Can sign back in
- [ ] Previous session data cleared

## 🐛 Troubleshooting Completed

If you encountered issues, check off what you tried:

- [ ] Cleaned build folder (⇧⌘K)
- [ ] Reset package cache (File → Packages → Reset Package Caches)
- [ ] Restarted Xcode
- [ ] Checked console logs for errors
- [ ] Verified Supabase credentials
- [ ] Checked network connectivity
- [ ] Verified database has data
- [ ] Checked RLS policies
- [ ] Read error messages carefully
- [ ] Consulted SETUP_GUIDE.md
- [ ] Checked Supabase dashboard

## 📱 Optional Enhancements

Once basic app is working, consider:

- [ ] Customized app colors
- [ ] Added app icon (Assets.xcassets)
- [ ] Customized launch screen
- [ ] Changed bundle identifier
- [ ] Added dark mode support
- [ ] Optimized for iPad
- [ ] Added app description
- [ ] Set up TestFlight
- [ ] Prepared for App Store

## 📚 Documentation Reviewed

- [ ] Read README.md
- [ ] Read QUICK_START.md
- [ ] Reviewed SETUP_GUIDE.md
- [ ] Reviewed ARCHITECTURE.md
- [ ] Read PROJECT_SUMMARY.md
- [ ] Understand code structure
- [ ] Know where to add features

## ✅ Success Criteria Met

Your app is ready when:

- [ ] ✅ Builds without errors
- [ ] ✅ Runs on simulator
- [ ] ✅ Can create account
- [ ] ✅ Can sign in
- [ ] ✅ Jobs load correctly
- [ ] ✅ Can view job details
- [ ] ✅ Can complete actions
- [ ] ✅ Can add notes
- [ ] ✅ Progress updates work
- [ ] ✅ Can sign out

## 🎉 Next Steps

Now that your app is working:

1. **Customize**
   - [ ] Update colors to match brand
   - [ ] Add company logo
   - [ ] Customize wording

2. **Test**
   - [ ] Test with real users
   - [ ] Test all edge cases
   - [ ] Test error scenarios
   - [ ] Test with poor network

3. **Extend**
   - [ ] Add new features
   - [ ] Integrate push notifications
   - [ ] Add offline support
   - [ ] Implement camera

4. **Deploy**
   - [ ] Set up TestFlight
   - [ ] Invite beta testers
   - [ ] Gather feedback
   - [ ] Prepare App Store listing

## 📊 Progress Tracker

Count your checkmarks:

- **0-20 checked**: Just getting started
- **21-40 checked**: Good progress
- **41-60 checked**: Almost there
- **61+ checked**: App is working! 🎉

---

**Tip:** Save this file and check items off as you complete them. You can commit it to git to track your team's progress!

**Last Updated:** 2025-10-13

