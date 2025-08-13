#!/bin/bash

echo "🐳 Docker APK Builder - Korean Administrative Services"
echo "===================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
check_docker() {
    print_info "Checking Docker status..."
    if ! docker info >/dev/null 2>&1; then
        print_warning "Docker is not running. Please start Docker Desktop."
        print_info "Starting Docker Desktop automatically..."
        
        # Try to start Docker Desktop
        open -a Docker
        
        print_info "Waiting for Docker to start (this may take a minute)..."
        
        # Wait for Docker to be ready (max 2 minutes)
        for i in {1..24}; do
            if docker info >/dev/null 2>&1; then
                print_status "Docker is now running!"
                return 0
            fi
            echo -n "."
            sleep 5
        done
        
        print_error "Docker failed to start. Please start Docker Desktop manually."
        return 1
    else
        print_status "Docker is running"
        return 0
    fi
}

# Build APK using Docker
build_apk_docker() {
    local app_path="$1"
    local app_name="$2"
    
    print_info "Building $app_name APK using Docker..."
    print_info "App path: $app_path"
    
    if [ ! -d "$app_path" ]; then
        print_error "App directory not found: $app_path"
        return 1
    fi
    
    # Pull Flutter Docker image if not exists
    print_info "Ensuring Flutter Docker image is available..."
    docker pull cirrusci/flutter:stable
    
    # Build APK using Docker
    print_info "Starting Docker build for $app_name..."
    if docker run --rm \
        -v "$app_path:/app" \
        -w /app \
        cirrusci/flutter:stable \
        sh -c "
            echo '📦 Installing Flutter dependencies...' &&
            flutter pub get &&
            echo '🛠️ Building APK for $app_name...' &&
            flutter build apk --release --verbose &&
            echo '✅ APK build completed for $app_name!'
        "; then
        
        print_status "$app_name APK built successfully!"
        
        # Check if APK was created
        local apk_file="$app_path/build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$apk_file" ]; then
            local apk_size=$(ls -lh "$apk_file" | awk '{print $5}')
            print_status "APK location: $apk_file"
            print_status "APK size: $apk_size"
            
            # Copy APK to main directory with descriptive name
            local timestamp=$(date +"%Y%m%d_%H%M")
            local apk_name="${app_name// /_}_${timestamp}.apk"
            local main_dir="/Users/yujumyeong/coding projects/행정사"
            
            cp "$apk_file" "$main_dir/$apk_name"
            print_status "APK copied to: $main_dir/$apk_name"
            
            return 0
        else
            print_error "APK file not found at expected location"
            return 1
        fi
    else
        print_error "Docker build failed for $app_name"
        return 1
    fi
}

# Main execution
main() {
    echo ""
    
    # Check Docker
    if ! check_docker; then
        exit 1
    fi
    
    echo ""
    print_info "Starting APK builds using Docker..."
    print_info "This process will download Flutter Docker image (~1GB) if not already available"
    echo ""
    
    local main_app_path="/Users/yujumyeong/coding projects/행정사/행정도우미"
    local admin_app_path="/Users/yujumyeong/coding projects/행정사/admin_app"
    
    local main_success=0
    local admin_success=0
    
    # Build Main App APK
    print_info "=== Building Main App APK ==="
    if build_apk_docker "$main_app_path" "Korean_Admin_Main_App"; then
        main_success=1
        print_status "Main App APK build completed successfully!"
    else
        print_error "Main App APK build failed"
    fi
    
    echo ""
    
    # Build Admin App APK
    print_info "=== Building Admin App APK ==="
    if build_apk_docker "$admin_app_path" "Korean_Admin_Panel_App"; then
        admin_success=1
        print_status "Admin App APK build completed successfully!"
    else
        print_error "Admin App APK build failed"
    fi
    
    echo ""
    print_info "=== Build Summary ==="
    
    if [ $main_success -eq 1 ]; then
        print_status "Main App APK: ✅ Success"
    else
        print_error "Main App APK: ❌ Failed"
    fi
    
    if [ $admin_success -eq 1 ]; then
        print_status "Admin App APK: ✅ Success"
    else
        print_error "Admin App APK: ❌ Failed"
    fi
    
    echo ""
    
    if [ $main_success -eq 1 ] || [ $admin_success -eq 1 ]; then
        print_status "APK files created in main directory:"
        ls -la "/Users/yujumyeong/coding projects/행정사"/*.apk 2>/dev/null || print_warning "No APK files found"
        
        echo ""
        print_info "📱 To install APKs on Android device:"
        print_info "1. Enable 'Unknown Sources' in Android settings"
        print_info "2. Transfer APK files to device"
        print_info "3. Tap APK file to install"
        print_info "4. Or use: adb install <apk-file>"
    fi
    
    print_status "Docker APK build process completed! 🎉"
}

# Run main function
main "$@"