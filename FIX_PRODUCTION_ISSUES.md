# Production Issues Fix Guide

## 🚨 Critical Issues Found and Fixes Applied

### ✅ 1. Removed Hardcoded Admin Password
- **Fixed:** Admin password now uses environment variable
- **Usage:** `flutter run --dart-define=ADMIN_PASSWORD=your_secure_password`
- **Location:** `행정도우미/lib/screens/terms_consent_screen.dart`

### ✅ 2. Removed Debug Navigation Button
- **Fixed:** Removed debug button that bypassed form submission
- **Location:** `행정도우미/lib/screens/contact_screen.dart`

## 🔧 Remaining Issues to Fix

### 1. Remove Print Statements (70+ found)

Run this command to remove all print statements:
```bash
# For macOS/Linux
find . -name "*.dart" -type f -exec sed -i '' '/print(/d' {} +

# Or manually comment them for debugging:
find . -name "*.dart" -type f -exec sed -i '' 's/print(/#print(/g' {} +
```

### 2. Critical Print Statements to Remove

**행정도우미/lib/screens/contact_screen.dart:**
- Lines: 226, 237, 284-287, 350-354

**행정도우미/lib/services/supabase_service.dart:**
- Lines: 108-110 (error logging)

**행정도우미/lib/services/webhook_service.dart:**
- Lines: 16, 43, 46, 50, 62, 86, 89, 93

**admin_app/lib/providers/application_provider.dart:**
- Lines: 16, 49, 65

### 3. Environment Variables Setup

Create `.env` file in each app:

**행정도우미/.env:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ADMIN_PASSWORD=your-secure-password
```

**admin_app/.env:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

### 4. Replace Hardcoded URLs

**Files to update:**
- `행정도우미/lib/services/webhook_service.dart` - Lines with webhook URLs
- `행정도우미/lib/config/env.dart` - Supabase configuration
- `admin_app/lib/config/env.dart` - Supabase configuration

### 5. Add Proper Error Handling

**Replace generic error messages with specific ones:**

```dart
// Instead of:
throw Exception('Failed to submit lead: $e');

// Use:
if (e is PostgrestException) {
  if (e.code == 'PGRST204') {
    throw Exception('데이터베이스 구조 오류가 발생했습니다. 관리자에게 문의하세요.');
  } else if (e.code == '23505') {
    throw Exception('이미 등록된 정보입니다.');
  }
}
throw Exception('일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
```

### 6. Add Loading States

**Example implementation:**
```dart
class _ContactScreenState extends State<ContactScreen> {
  bool _isSubmitting = false;
  
  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);
    try {
      // ... submission logic
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _isSubmitting ? '제출 중...' : '제출하기',
      onPressed: _isSubmitting ? null : _submitForm,
      child: _isSubmitting 
        ? CircularProgressIndicator(color: Colors.white)
        : null,
    );
  }
}
```

### 7. Input Validation Improvements

**Use the validators we created:**
```dart
import 'package:your_app/utils/validators.dart';

// In form validation:
if (!Validators.isValidKoreanPhone(_phoneController.text)) {
  setState(() {
    _phoneError = '올바른 전화번호 형식이 아닙니다 (예: 010-1234-5678)';
  });
  return;
}

if (!Validators.isValidEmail(_emailController.text)) {
  setState(() {
    _emailError = '올바른 이메일 형식이 아닙니다';
  });
  return;
}
```

### 8. Remove TODO Comments

**Files with TODOs:**
- `행정도우미/lib/data/steps.dart` - Lines 9-10
- `admin_app/lib/screens/applications_screen.dart` - Line 645
- Multiple service files

### 9. Performance Optimizations

**Add const constructors:**
```dart
// Instead of:
SizedBox(height: 8)

// Use:
const SizedBox(height: 8)
```

**Use ListView.builder for long lists:**
```dart
// Instead of:
Column(children: items.map((item) => Widget(item)).toList())

// Use:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => Widget(items[index]),
)
```

### 10. Security Headers for Web

**Update web/index.html:**
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';">
<meta http-equiv="X-Content-Type-Options" content="nosniff">
<meta http-equiv="X-Frame-Options" content="DENY">
```

## 📋 Pre-Production Checklist

- [ ] Remove all print statements
- [ ] Replace hardcoded URLs with environment variables
- [ ] Add proper error handling with user-friendly messages
- [ ] Implement loading states for all async operations
- [ ] Add input validation with real-time feedback
- [ ] Remove or implement all TODO items
- [ ] Add const constructors where possible
- [ ] Test all error scenarios
- [ ] Review and test security policies
- [ ] Set up proper logging (not console.log/print)
- [ ] Configure production environment variables
- [ ] Test on different devices and browsers
- [ ] Run Flutter analyzer: `flutter analyze`
- [ ] Check for unused dependencies: `flutter pub deps`
- [ ] Build release version: `flutter build web --release`

## 🚀 Build Commands

### Development with security:
```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ADMIN_PASSWORD=secure_password
```

### Production build:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ADMIN_PASSWORD=secure_password
```

## 🔍 Testing Commands

### Run analyzer:
```bash
flutter analyze
```

### Format code:
```bash
flutter format lib/
```

### Run tests:
```bash
flutter test
```

## 📊 Summary

**Fixed:**
- ✅ Hardcoded admin password
- ✅ Debug navigation button

**High Priority Remaining:**
- 🔴 70+ print statements
- 🔴 Hardcoded URLs and keys
- 🔴 Missing error handling
- 🔴 No loading states

**Medium Priority:**
- 🟡 TODO items (16)
- 🟡 Performance optimizations
- 🟡 Input validation improvements

**Low Priority:**
- 🟢 Code formatting
- 🟢 Documentation
- 🟢 Unit tests