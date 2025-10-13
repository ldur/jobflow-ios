#!/bin/bash

# Script to help create the Xcode project for KindredFlowGraphiOS
# This script provides guidance for manual project setup

echo "================================================"
echo "Kindred Flow Graph iOS - Xcode Project Setup"
echo "================================================"
echo ""
echo "This script will guide you through setting up the Xcode project."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"
echo ""

# Check if Config.xcconfig exists
if [ ! -f "Config.xcconfig" ]; then
    echo "⚠️  Config.xcconfig not found"
    echo ""
    echo "Creating Config.xcconfig from example..."
    
    if [ -f "Config.xcconfig.example" ]; then
        cp Config.xcconfig.example Config.xcconfig
        echo "✅ Config.xcconfig created"
        echo ""
        echo "📝 IMPORTANT: Edit Config.xcconfig and add your Supabase credentials:"
        echo "   - SUPABASE_URL"
        echo "   - SUPABASE_ANON_KEY"
        echo ""
        echo "Get these from: https://app.supabase.com -> Your Project -> Settings -> API"
        echo ""
        
        # Prompt user to edit the file
        read -p "Press ENTER to open Config.xcconfig in your default editor..." -r
        open Config.xcconfig
        
        echo ""
        read -p "Have you added your Supabase credentials? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Please edit Config.xcconfig with your credentials before continuing."
            exit 1
        fi
    else
        echo "❌ Error: Config.xcconfig.example not found"
        exit 1
    fi
else
    echo "✅ Config.xcconfig found"
fi

echo ""
echo "================================================"
echo "Next Steps - Manual Xcode Project Creation"
echo "================================================"
echo ""
echo "1. Open Xcode"
echo "2. File > New > Project"
echo "3. Choose: iOS > App"
echo "4. Project Details:"
echo "   - Product Name: KindredFlowGraphiOS"
echo "   - Team: (Select your team)"
echo "   - Organization Identifier: com.kindred (or your own)"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Storage: None"
echo "   - Create Git repository: No (already in Git)"
echo "5. Save Location: Select THIS directory"
echo "   $(pwd)"
echo ""
echo "6. After project creation:"
echo "   a. Delete these auto-generated files:"
echo "      - ContentView.swift (we have our own)"
echo "      - KindredFlowGraphiOSApp.swift (we have our own)"
echo ""
echo "   b. Add project files to Xcode:"
echo "      - Right-click project in navigator"
echo "      - Add Files to 'KindredFlowGraphiOS'"
echo "      - Select: KindredFlowGraphiOS folder"
echo "      - Check: 'Create groups'"
echo "      - Check: 'Add to targets: KindredFlowGraphiOS'"
echo "      - Click Add"
echo ""
echo "   c. Add Supabase Swift Package:"
echo "      - Select project in navigator"
echo "      - Select target > General tab"
echo "      - Scroll to 'Frameworks, Libraries, and Embedded Content'"
echo "      - Click '+'"
echo "      - 'Add Package Dependency'"
echo "      - URL: https://github.com/supabase/supabase-swift.git"
echo "      - Version: 2.0.0 (Up to Next Major Version)"
echo "      - Select 'Supabase' product"
echo "      - Click 'Add Package'"
echo ""
echo "   d. Configure Environment Variables:"
echo "      - Click scheme (top bar) > Edit Scheme"
echo "      - Run > Arguments tab"
echo "      - Under 'Environment Variables', add:"
echo "        * SUPABASE_URL = (your Supabase URL)"
echo "        * SUPABASE_ANON_KEY = (your Supabase anon key)"
echo ""
echo "   e. Build and Run:"
echo "      - Select a simulator"
echo "      - Press ⌘+R"
echo ""
echo "================================================"
echo "Alternative: Use Provided Xcode Project"
echo "================================================"
echo ""
echo "If you prefer, you can use the pre-configured Xcode project"
echo "that may be provided in the repository. Look for:"
echo "  - KindredFlowGraphiOS.xcodeproj"
echo ""
echo "Just open it and configure the environment variables in the scheme."
echo ""

read -p "Press ENTER to open Xcode..." -r
open -a Xcode .

echo ""
echo "✨ Setup guidance complete!"
echo ""
echo "📚 For detailed instructions, see: SETUP_GUIDE.md"
echo "❓ For help, see: README.md"
echo ""

