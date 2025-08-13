/// Rate limiter to prevent abuse and spam
class RateLimiter {
  static final Map<String, DateTime> _lastAttempts = {};
  static final Map<String, int> _attemptCounts = {};
  static const Duration _cooldownPeriod = Duration(minutes: 1);
  static const int _maxAttemptsPerHour = 10;
  
  /// Check if an action is allowed based on rate limiting
  static bool isAllowed(String action) {
    final now = DateTime.now();
    final lastAttempt = _lastAttempts[action];
    
    // First attempt is always allowed
    if (lastAttempt == null) {
      _lastAttempts[action] = now;
      _attemptCounts[action] = 1;
      return true;
    }
    
    // Check cooldown period
    if (now.difference(lastAttempt) < _cooldownPeriod) {
      return false;
    }
    
    // Reset counter if more than an hour has passed
    if (now.difference(lastAttempt) > const Duration(hours: 1)) {
      _attemptCounts[action] = 0;
    }
    
    // Check hourly limit
    final count = _attemptCounts[action] ?? 0;
    if (count >= _maxAttemptsPerHour) {
      return false;
    }
    
    // Allow the action
    _lastAttempts[action] = now;
    _attemptCounts[action] = count + 1;
    return true;
  }
  
  /// Get remaining cooldown time in seconds
  static int getRemainingCooldown(String action) {
    final lastAttempt = _lastAttempts[action];
    if (lastAttempt == null) return 0;
    
    final elapsed = DateTime.now().difference(lastAttempt);
    final remaining = _cooldownPeriod - elapsed;
    
    if (remaining.isNegative) return 0;
    return remaining.inSeconds;
  }
  
  /// Reset rate limiting for a specific action
  static void reset(String action) {
    _lastAttempts.remove(action);
    _attemptCounts.remove(action);
  }
  
  /// Clear all rate limiting data
  static void clearAll() {
    _lastAttempts.clear();
    _attemptCounts.clear();
  }
}