# 🧪 Testing Guide

## Quick Start (5 minutes)

### Prerequisites
- Git installed
- Flutter SDK (3.0+) - [Install Guide](https://flutter.dev/docs/get-started/install)
- Chrome or Edge browser

### Steps

1. **Clone the repository:**
```bash
git clone https://github.com/dan914/korean-admin-services-app.git
cd korean-admin-services-app
```

2. **Run the automated test script:**
```bash
chmod +x test_on_desktop.sh
./test_on_desktop.sh
```

3. **Or manually test:**
```bash
# Install dependencies
cd 행정도우미 && flutter pub get && cd ..
cd admin_app && flutter pub get && cd ..

# Run both apps
cd 행정도우미 && flutter run -d chrome &
cd ../admin_app && flutter run -d chrome &
```

## Test Scenarios

### 1. Main App (행정도우미)
- **Home Page**: Check landing page loads
- **Wizard Flow**: 
  - Click "시작하기" (Start)
  - Complete all 10 steps
  - Fill contact form
  - Submit (will work in offline mode)
- **Admin Access**: 
  - Go to Terms page
  - Triple-click title
  - Enter admin password: `TestAdmin123`

### 2. Admin Panel
- **Login**: Use test credentials (if Supabase configured)
- **Dashboard**: View statistics
- **Applications**: Test pagination, search, filters
- **Session Timeout**: Wait 30 minutes for auto-logout

## Testing Environments

### Offline Mode (No Database)
```bash
flutter run -d chrome
```
- ✅ UI/UX testing
- ✅ Form validation
- ✅ Navigation flow
- ❌ Data persistence
- ❌ Authentication

### Online Mode (With Supabase)
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```
- ✅ Full functionality
- ✅ Data persistence
- ✅ Authentication
- ✅ Real-time updates

## Platform-Specific Testing

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

### Mobile (iOS/Android)
```bash
flutter run -d ios    # Requires Xcode
flutter run -d android # Requires Android Studio
```

## Test Checklist

### Security Testing
- [ ] Rate limiting works (try submitting form multiple times)
- [ ] Session timeout after 30 minutes
- [ ] Input validation prevents XSS
- [ ] File upload restrictions work
- [ ] No console errors in production mode

### Functionality Testing
- [ ] Complete wizard flow
- [ ] Submit contact form
- [ ] Admin login/logout
- [ ] Pagination in admin panel
- [ ] Search and filters work
- [ ] Real-time validation feedback

### Performance Testing
- [ ] Page load time < 3 seconds
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Responsive on all screen sizes

### Browser Testing
- [ ] Chrome
- [ ] Firefox
- [ ] Safari
- [ ] Edge

## Troubleshooting

### Flutter not found
```bash
# Install Flutter
curl -fsSL https://flutter.dev/setup.sh | bash
export PATH="$PATH:$HOME/flutter/bin"
```

### Dependencies error
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Build errors
```bash
flutter doctor -v  # Check environment
flutter analyze    # Check code issues
```

### Port already in use
```bash
# Kill existing Flutter processes
killall flutter
# Or use different port
flutter run -d chrome --web-port=8090
```

## Test Data

### Sample Form Inputs
- **Name**: 홍길동
- **Phone**: 010-1234-5678
- **Email**: test@example.com
- **Purpose**: 피해 구제
- **Business Type**: 개인

### Admin Credentials (for Supabase)
- **Email**: admin@yourdomain.com
- **Password**: (set in Supabase Auth)

## Automated Testing

### Run all tests
```bash
cd 행정도우미
flutter test
flutter analyze

cd ../admin_app
flutter test
flutter analyze
```

### Check dependencies
```bash
./check_dependencies.sh
```

## Performance Monitoring

### Chrome DevTools
1. Run app: `flutter run -d chrome`
2. Press `F12` in Chrome
3. Go to Performance tab
4. Record user interactions

### Flutter Inspector
1. Run app in debug mode
2. Press `i` in terminal
3. Use widget inspector

## Bug Reporting

If you find issues:
1. Check browser console for errors
2. Take screenshots
3. Note reproduction steps
4. Report at: https://github.com/dan914/korean-admin-services-app/issues

## Support

- **Documentation**: See `/docs` folder
- **Security Issues**: See `SECURITY_AUDIT.md`
- **Deployment**: See `DEPLOYMENT_GUIDE.md`