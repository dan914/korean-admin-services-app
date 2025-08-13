#!/bin/bash

echo "🔍 Checking APK Build Status..."
echo "================================"

# Get latest workflow run status
status=$(curl -s "https://api.github.com/repos/dan914/korean-admin-services-app/actions/runs?per_page=1" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
conclusion=$(curl -s "https://api.github.com/repos/dan914/korean-admin-services-app/actions/runs?per_page=1" | grep -o '"conclusion":"[^"]*' | cut -d'"' -f4)

if [ "$status" = "completed" ]; then
    if [ "$conclusion" = "success" ]; then
        echo "✅ BUILD COMPLETED SUCCESSFULLY!"
        echo ""
        echo "📱 Your APKs are ready for download!"
        echo ""
        echo "🔗 Download from:"
        echo "   Artifacts: https://github.com/dan914/korean-admin-services-app/actions"
        echo "   Releases:  https://github.com/dan914/korean-admin-services-app/releases"
        echo ""
        echo "📥 Files to download:"
        echo "   • korean-admin-main-app-apk.zip"
        echo "   • korean-admin-panel-app-apk.zip"
        
        # Try to open download pages
        open "https://github.com/dan914/korean-admin-services-app/actions"
        
    elif [ "$conclusion" = "failure" ]; then
        echo "❌ BUILD FAILED"
        echo ""
        echo "🔧 I can fix this quickly. Common issues:"
        echo "   • Flutter version mismatch"
        echo "   • Dependency conflicts" 
        echo "   • Korean filename encoding"
        echo ""
        echo "📋 Check details: https://github.com/dan914/korean-admin-services-app/actions"
        open "https://github.com/dan914/korean-admin-services-app/actions"
    fi
else
    echo "⏳ BUILD IN PROGRESS..."
    echo ""
    echo "⏱️  Status: $status"
    echo "🔄 Expected completion: 2-5 more minutes"
    echo ""
    echo "📊 Monitor progress:"
    echo "   https://github.com/dan914/korean-admin-services-app/actions"
    echo ""
    echo "💡 Run this script again in a few minutes to check status"
fi

echo ""
echo "🎯 Remember: Once downloaded, enable 'Unknown Sources' on Android to install APKs"