#!/bin/bash

echo "🚀 Korean Administrative Services - Android APK Builder"
echo "====================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Android Studio is installed
check_android_studio() {
    if [ -d "/Applications/Android Studio.app" ]; then
        print_status "Android Studio found"
        return 0
    else
        return 1
    fi
}

# Install Android Studio if not found
install_android_studio() {
    print_warning "Installing Android Studio via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install --cask android-studio
        if [ $? -eq 0 ]; then
            print_status "Android Studio installation completed"
            return 0
        else
            print_error "Failed to install Android Studio"
            return 1
        fi
    else
        print_error "Homebrew not found. Please install manually from:"
        echo "https://developer.android.com/studio"
        return 1
    fi
}

# Configure Flutter for Android
configure_flutter_android() {
    print_status "Configuring Flutter for Android development..."
    
    # Try to find Android SDK path
    ANDROID_SDK_PATHS=(
        "/Applications/Android Studio.app/Contents/android-sdk"
        "$HOME/Library/Android/sdk"
        "$HOME/Android/Sdk"
        "/usr/local/Caskroom/android-studio/*/Android Studio.app/Contents/android-sdk"
    )
    
    for path in "${ANDROID_SDK_PATHS[@]}"; do
        if [ -d "$path" ] || ls $path > /dev/null 2>&1; then
            export ANDROID_HOME="$path"
            export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
            flutter config --android-sdk "$path"
            print_status "Android SDK configured at: $path"
            return 0
        fi
    done
    
    print_warning "Android SDK not found. Please set ANDROID_HOME manually after setup."
    return 1
}

# Accept Android licenses
accept_android_licenses() {
    print_status "Accepting Android licenses..."
    if command -v flutter &> /dev/null; then
        yes | flutter doctor --android-licenses 2>/dev/null || true
        print_status "Android licenses accepted"
    fi
}

# Build APK for an app
build_apk() {
    local app_path="$1"
    local app_name="$2"
    
    echo ""
    print_status "Building APK for $app_name..."
    
    if [ ! -d "$app_path" ]; then
        print_error "App directory not found: $app_path"
        return 1
    fi
    
    cd "$app_path"
    
    # Clean and get dependencies
    flutter clean
    flutter pub get
    
    # Build APK
    if flutter build apk --release; then
        print_status "$app_name APK built successfully!"
        
        # Check if APK was created
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            local apk_size=$(ls -lh "build/app/outputs/flutter-apk/app-release.apk" | awk '{print $5}')
            print_status "APK location: $app_path/build/app/outputs/flutter-apk/app-release.apk"
            print_status "APK size: $apk_size"
            
            # Copy APK to main directory with descriptive name
            local main_dir="/Users/yujumyeong/coding projects/행정사"
            local apk_name="${app_name// /_}_$(date +%Y%m%d).apk"
            cp "build/app/outputs/flutter-apk/app-release.apk" "$main_dir/$apk_name"
            print_status "APK copied to: $main_dir/$apk_name"
        else
            print_error "APK file not found after build"
            return 1
        fi
    else
        print_error "Failed to build $app_name APK"
        return 1
    fi
    
    cd - > /dev/null
    return 0
}

# Main execution
main() {
    echo ""
    
    # Check current Flutter status
    print_status "Checking Flutter environment..."
    flutter doctor
    
    echo ""
    
    # Check Android Studio
    if ! check_android_studio; then
        print_warning "Android Studio not found. Installing..."
        if ! install_android_studio; then
            print_error "Please install Android Studio manually and re-run this script."
            exit 1
        fi
        
        # Wait for user to set up Android Studio
        echo ""
        print_warning "Please complete the Android Studio setup:"
        print_warning "1. Open Android Studio"
        print_warning "2. Complete the setup wizard"
        print_warning "3. Install Android SDK"
        print_warning "4. Press Enter when ready to continue..."
        read -r
    fi
    
    # Configure Flutter
    configure_flutter_android
    accept_android_licenses
    
    echo ""
    print_status "Checking Flutter environment after configuration..."
    flutter doctor
    
    # Build APKs
    echo ""
    print_status "Starting APK builds..."
    
    # Build main app APK
    if build_apk "/Users/yujumyeong/coding projects/행정사/행정도우미" "Main App"; then
        echo ""
        print_status "Main App APK build completed!"
    else
        print_error "Main App APK build failed"
    fi
    
    # Build admin app APK
    if build_apk "/Users/yujumyeong/coding projects/행정사/admin_app" "Admin App"; then
        echo ""
        print_status "Admin App APK build completed!"
    else
        print_error "Admin App APK build failed"
    fi
    
    echo ""
    print_status "APK build process completed!"
    print_status "Check the main project directory for APK files."
    
    # List generated APKs
    echo ""
    print_status "Generated APK files:"
    ls -la "/Users/yujumyeong/coding projects/행정사"/*.apk 2>/dev/null || print_warning "No APK files found in main directory"
}

# Run main function
main "$@"