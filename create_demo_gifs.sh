#!/bin/bash

echo "🎬 Creating Demo GIFs of Korean Administrative Services Apps"
echo "=========================================================="

# Check if apps are running
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Main app not running at localhost:8080"
    echo "Please start with: cd 행정도우미 && flutter run -d chrome --web-port=8080"
    exit 1
fi

if ! curl -s http://localhost:8090 > /dev/null; then
    echo "❌ Admin app not running at localhost:8090" 
    echo "Please start with: cd admin_app && flutter run -d chrome --web-port=8090"
    exit 1
fi

echo "✅ Both apps are running"

# Instructions for creating GIFs
echo ""
echo "🎥 How to Create Demo GIFs:"
echo ""
echo "Option 1: Using macOS Screen Recording"
echo "1. Press Cmd+Shift+5 to open screen recording"
echo "2. Select 'Record Selected Portion'"
echo "3. Record your app interactions"
echo "4. Convert to GIF using online tools"
echo ""
echo "Option 2: Using Chrome DevTools"
echo "1. Open app in Chrome"
echo "2. Press F12 → Performance tab"
echo "3. Start recording"
echo "4. Interact with app"
echo "5. Export as screenshots"
echo ""
echo "Option 3: Using Browser Extensions"
echo "1. Install 'Loom' or 'Screencastify' Chrome extension"
echo "2. Record browser tab"
echo "3. Export as GIF"
echo ""

echo "📱 Suggested GIF Content:"
echo "Main App Demo:"
echo "- Homepage → Start button → Wizard steps → Form → Submission"
echo ""
echo "Admin Panel Demo:" 
echo "- Dashboard → Applications → Pagination → Search"
echo ""

echo "🎯 Apps Ready for Recording:"
echo "Main App: http://localhost:8080"
echo "Admin Panel: http://localhost:8090"