#!/bin/bash

echo "🐳 Docker-based APK Builder for Korean Administrative Services"
echo "============================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    echo "Download from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker found"

# Build main app APK using Docker
echo "🚀 Building Main App APK using Docker..."
docker run --rm -v "$PWD/행정도우미:/app" -w /app cirrusci/flutter:stable sh -c "
    echo 'Installing dependencies...' &&
    flutter pub get &&
    echo 'Building APK...' &&
    flutter build apk --release &&
    echo 'APK build completed!'
"

if [ $? -eq 0 ]; then
    echo "✅ Main App APK built successfully!"
    # Copy APK to main directory
    cp "행정도우미/build/app/outputs/flutter-apk/app-release.apk" "Korean_Admin_Main_App_$(date +%Y%m%d).apk"
    echo "📱 Main App APK: Korean_Admin_Main_App_$(date +%Y%m%d).apk"
else
    echo "❌ Main App APK build failed"
fi

# Build admin app APK using Docker
echo "🚀 Building Admin App APK using Docker..."
docker run --rm -v "$PWD/admin_app:/app" -w /app cirrusci/flutter:stable sh -c "
    echo 'Installing dependencies...' &&
    flutter pub get &&
    echo 'Building APK...' &&
    flutter build apk --release &&
    echo 'APK build completed!'
"

if [ $? -eq 0 ]; then
    echo "✅ Admin App APK built successfully!"
    # Copy APK to main directory
    cp "admin_app/build/app/outputs/flutter-apk/app-release.apk" "Korean_Admin_Panel_App_$(date +%Y%m%d).apk"
    echo "📱 Admin App APK: Korean_Admin_Panel_App_$(date +%Y%m%d).apk"
else
    echo "❌ Admin App APK build failed"
fi

echo "🎉 Docker APK build process completed!"
echo "📂 Check current directory for APK files:"
ls -la *.apk 2>/dev/null || echo "No APK files found"