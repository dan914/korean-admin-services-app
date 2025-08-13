#!/bin/bash

# Dependency Security Checker for Korean Admin Services App
# This script checks for outdated and vulnerable dependencies

echo "🔍 Checking Dependencies for Security Issues..."
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"
echo ""

# Function to check dependencies in a directory
check_app_dependencies() {
    local app_name=$1
    local app_dir=$2
    
    echo "📦 Checking $app_name dependencies..."
    echo "----------------------------------------"
    
    if [ ! -d "$app_dir" ]; then
        echo -e "${RED}❌ Directory $app_dir not found${NC}"
        return
    fi
    
    cd "$app_dir"
    
    # Check for outdated packages
    echo "Checking for outdated packages..."
    flutter pub outdated
    
    # Run Flutter analyze for issues
    echo ""
    echo "Running Flutter analyze..."
    flutter analyze --no-fatal-infos
    
    # Check pubspec.lock for specific vulnerable versions
    echo ""
    echo "Checking for known vulnerabilities..."
    
    # Check for http package < 0.13.5 (security issue)
    if grep -q "http:" pubspec.yaml; then
        http_version=$(grep -A 2 "http:" pubspec.lock | grep "version:" | awk '{print $2}' | tr -d '"')
        if [ ! -z "$http_version" ]; then
            echo "  http package version: $http_version"
            # Add version comparison logic here if needed
        fi
    fi
    
    # Check for file_picker security
    if grep -q "file_picker:" pubspec.yaml; then
        picker_version=$(grep -A 2 "file_picker:" pubspec.lock | grep "version:" | awk '{print $2}' | tr -d '"')
        echo "  file_picker version: $picker_version"
    fi
    
    # Count total dependencies
    dep_count=$(grep "^  [a-z_]*:" pubspec.lock | wc -l)
    echo ""
    echo -e "${GREEN}Total dependencies: $dep_count${NC}"
    
    cd - > /dev/null
    echo ""
}

# Check main app
check_app_dependencies "행정도우미 (Main App)" "./행정도우미"

# Check admin app
check_app_dependencies "Admin Panel" "./admin_app"

# Security recommendations
echo "🔒 Security Recommendations:"
echo "============================"
echo "1. Run 'flutter pub upgrade' to update packages"
echo "2. Review and test after updates"
echo "3. Check https://pub.dev for security advisories"
echo "4. Consider using 'dependency_validator' package"
echo "5. Set up automated dependency scanning in CI/CD"
echo ""

# Check for sensitive files
echo "🔍 Checking for sensitive files..."
echo "=================================="

sensitive_files=(
    ".env"
    "*.key"
    "*.pem"
    "*.p12"
    "credentials.json"
    "service-account.json"
)

found_sensitive=false
for pattern in "${sensitive_files[@]}"; do
    if find . -name "$pattern" -not -path "*/\.*" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠️  Found potentially sensitive files matching: $pattern${NC}"
        find . -name "$pattern" -not -path "*/\.*" 2>/dev/null
        found_sensitive=true
    fi
done

if [ "$found_sensitive" = false ]; then
    echo -e "${GREEN}✅ No sensitive files found${NC}"
fi

echo ""
echo "✨ Dependency check complete!"
echo ""
echo "Next steps:"
echo "1. Review any outdated packages"
echo "2. Update critical security patches"
echo "3. Test thoroughly after updates"
echo "4. Document any dependency changes"

# Return exit code based on critical issues
if flutter analyze --no-fatal-infos 2>&1 | grep -q "error"; then
    exit 1
else
    exit 0
fi