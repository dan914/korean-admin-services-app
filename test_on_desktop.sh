#!/bin/bash

echo "🚀 Korean Admin Services App - Desktop Test Script"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter installation
check_flutter() {
    if command -v flutter &> /dev/null; then
        echo -e "${GREEN}✅ Flutter is installed${NC}"
        flutter --version | head -n 1
        return 0
    else
        echo -e "${RED}❌ Flutter is not installed${NC}"
        echo ""
        echo "Install Flutter:"
        echo "1. Download from https://flutter.dev/docs/get-started/install"
        echo "2. Or run: curl -fsSL https://flutter.dev/setup.sh | bash"
        return 1
    fi
}

# Install dependencies
install_deps() {
    echo ""
    echo "📦 Installing dependencies..."
    
    if [ -d "행정도우미" ]; then
        echo "Installing main app dependencies..."
        cd 행정도우미
        flutter pub get
        cd ..
    fi
    
    if [ -d "admin_app" ]; then
        echo "Installing admin app dependencies..."
        cd admin_app
        flutter pub get
        cd ..
    fi
}

# Run tests
run_tests() {
    echo ""
    echo "🧪 Running tests..."
    
    cd 행정도우미
    flutter analyze --no-fatal-warnings
    cd ../admin_app
    flutter analyze --no-fatal-warnings
    cd ..
}

# Main menu
show_menu() {
    echo ""
    echo "Choose test option:"
    echo "=================="
    echo "1) Test in Chrome (Web)"
    echo "2) Test in Edge (Web)"
    echo "3) Test in Desktop App (macOS/Windows/Linux)"
    echo "4) Build for production"
    echo "5) Run with custom Supabase"
    echo "6) Exit"
    echo ""
    read -p "Enter choice [1-6]: " choice
    
    case $choice in
        1)
            echo -e "${GREEN}Starting in Chrome...${NC}"
            cd 행정도우미 && flutter run -d chrome &
            cd admin_app && flutter run -d chrome &
            wait
            ;;
        2)
            echo -e "${GREEN}Starting in Edge...${NC}"
            cd 행정도우미 && flutter run -d edge &
            cd admin_app && flutter run -d edge &
            wait
            ;;
        3)
            echo -e "${GREEN}Starting Desktop App...${NC}"
            cd 행정도우미 && flutter run -d macos &
            cd admin_app && flutter run -d macos &
            wait
            ;;
        4)
            echo -e "${GREEN}Building for production...${NC}"
            cd 행정도우미 && flutter build web --release
            cd ../admin_app && flutter build web --release
            echo ""
            echo -e "${GREEN}✅ Build complete!${NC}"
            echo "Main app: 행정도우미/build/web"
            echo "Admin app: admin_app/build/web"
            ;;
        5)
            echo ""
            read -p "Enter Supabase URL: " SUPABASE_URL
            read -p "Enter Supabase Anon Key: " SUPABASE_KEY
            read -p "Enter Admin Password: " ADMIN_PWD
            
            echo -e "${GREEN}Starting with custom Supabase...${NC}"
            cd 행정도우미
            flutter run -d chrome \
                --dart-define=SUPABASE_URL=$SUPABASE_URL \
                --dart-define=SUPABASE_ANON_KEY=$SUPABASE_KEY \
                --dart-define=ADMIN_PASSWORD=$ADMIN_PWD &
            
            cd ../admin_app
            flutter run -d chrome \
                --dart-define=SUPABASE_URL=$SUPABASE_URL \
                --dart-define=SUPABASE_ANON_KEY=$SUPABASE_KEY &
            wait
            ;;
        6)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            show_menu
            ;;
    esac
}

# Main execution
main() {
    echo ""
    
    # Check if we're in the right directory
    if [ ! -d "행정도우미" ] || [ ! -d "admin_app" ]; then
        echo -e "${RED}❌ Error: Not in the correct directory${NC}"
        echo "Please run this script from the korean-admin-services-app root directory"
        exit 1
    fi
    
    # Check Flutter
    if ! check_flutter; then
        exit 1
    fi
    
    # Install dependencies
    install_deps
    
    # Run tests
    read -p "Run code analysis? (y/n): " run_analysis
    if [ "$run_analysis" = "y" ]; then
        run_tests
    fi
    
    # Show menu
    show_menu
}

# Run
main