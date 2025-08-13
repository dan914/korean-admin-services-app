/// Security validators for user input
class Validators {
  /// Validate Korean phone number
  static bool isValidKoreanPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    
    // Remove all non-digits
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Korean phone patterns:
    // Mobile: 010-XXXX-XXXX (most common)
    // Seoul: 02-XXXX-XXXX
    // Other cities: 0XX-XXXX-XXXX
    final regex = RegExp(r'^(01[0-9]|02|0[3-9][0-9])[0-9]{7,8}$');
    return regex.hasMatch(cleaned);
  }
  
  /// Format phone number for display
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length == 11) {
      // Mobile: 010-1234-5678
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      if (cleaned.startsWith('02')) {
        // Seoul: 02-1234-5678
        return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
      } else {
        // Other: 031-123-4567
        return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
      }
    }
    return phone;
  }
  
  /// Validate email address
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    
    // RFC 5322 compliant email regex (simplified to avoid quote issues)
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    
    // Additional checks
    if (email.length > 254) return false; // Max email length
    if (email.contains('..')) return false; // No consecutive dots
    if (email.startsWith('.') || email.endsWith('.')) return false;
    
    return regex.hasMatch(email);
  }
  
  /// Validate name (Korean or English)
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) return false;
    if (name.length < 2 || name.length > 50) return false;
    
    // Allow Korean, English, and spaces
    final regex = RegExp(r'^[가-힣a-zA-Z\s]+$');
    return regex.hasMatch(name);
  }
  
  /// Sanitize input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;')
        .replaceAll('\\', '&#x5C;')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();
  }
  
  /// Validate password strength
  static bool isStrongPassword(String? password) {
    if (password == null || password.length < 12) return false;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialChar;
  }
  
  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return '비밀번호를 입력하세요';
    if (password.length < 12) return '최소 12자 이상 입력하세요';
    if (!password.contains(RegExp(r'[A-Z]'))) return '대문자를 포함하세요';
    if (!password.contains(RegExp(r'[a-z]'))) return '소문자를 포함하세요';
    if (!password.contains(RegExp(r'[0-9]'))) return '숫자를 포함하세요';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return '특수문자를 포함하세요';
    return '안전한 비밀번호입니다';
  }
  
  /// Check for common SQL injection patterns
  static bool containsSQLInjection(String input) {
    final dangerous = [
      'DROP', 'DELETE', 'INSERT', 'UPDATE', 'SELECT',
      'UNION', 'WHERE', 'FROM', '--', '/*', '*/',
      'xp_', 'sp_', 'exec', 'execute', 'script',
      'javascript:', 'onclick', 'onerror', 'onload'
    ];
    
    final upperInput = input.toUpperCase();
    for (final pattern in dangerous) {
      if (upperInput.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
  
  /// Validate file upload
  static bool isValidFileUpload(String fileName, int fileSize) {
    // Check file size (max 10MB)
    if (fileSize > 10 * 1024 * 1024) return false;
    
    // Check file extension
    final allowedExtensions = [
      'pdf', 'jpg', 'jpeg', 'png', 'gif',
      'doc', 'docx', 'xls', 'xlsx', 'hwp'
    ];
    
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  /// Rate limit check (client-side)
  static final Map<String, List<DateTime>> _rateLimitMap = {};
  
  static bool checkRateLimit(String identifier, {int maxAttempts = 10, Duration window = const Duration(hours: 1)}) {
    final now = DateTime.now();
    final attempts = _rateLimitMap[identifier] ?? [];
    
    // Remove old attempts outside the window
    attempts.removeWhere((time) => now.difference(time) > window);
    
    if (attempts.length >= maxAttempts) {
      return false; // Rate limit exceeded
    }
    
    attempts.add(now);
    _rateLimitMap[identifier] = attempts;
    return true;
  }
}