import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

/// Manages user sessions with auto-logout after inactivity
class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();
  
  SessionManager._();
  
  Timer? _inactivityTimer;
  DateTime? _lastActivity;
  
  // Configuration
  static const Duration _inactivityTimeout = Duration(minutes: 30);
  static const Duration _warningTime = Duration(minutes: 25);
  
  VoidCallback? _onSessionExpired;
  VoidCallback? _onSessionWarning;
  
  /// Initialize session management
  void initialize({
    VoidCallback? onSessionExpired,
    VoidCallback? onSessionWarning,
  }) {
    _onSessionExpired = onSessionExpired;
    _onSessionWarning = onSessionWarning;
    _startMonitoring();
    Logger.info('Session manager initialized');
  }
  
  /// Record user activity
  void recordActivity() {
    _lastActivity = DateTime.now();
    _resetTimer();
  }
  
  /// Start monitoring for inactivity
  void _startMonitoring() {
    _lastActivity = DateTime.now();
    _resetTimer();
  }
  
  /// Reset the inactivity timer
  void _resetTimer() {
    _inactivityTimer?.cancel();
    
    // Set warning timer
    _inactivityTimer = Timer(_warningTime, () {
      Logger.warning('Session will expire in 5 minutes');
      _onSessionWarning?.call();
      
      // Set final expiration timer
      _inactivityTimer = Timer(
        _inactivityTimeout - _warningTime,
        _handleSessionExpired,
      );
    });
  }
  
  /// Handle session expiration
  void _handleSessionExpired() {
    Logger.warning('Session expired due to inactivity');
    _onSessionExpired?.call();
    dispose();
  }
  
  /// Get remaining session time
  Duration? getRemainingTime() {
    if (_lastActivity == null) return null;
    
    final elapsed = DateTime.now().difference(_lastActivity!);
    final remaining = _inactivityTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Check if session is about to expire
  bool isAboutToExpire() {
    final remaining = getRemainingTime();
    if (remaining == null) return false;
    
    return remaining < (_inactivityTimeout - _warningTime);
  }
  
  /// Extend session
  void extendSession() {
    recordActivity();
    Logger.info('Session extended');
  }
  
  /// End session manually
  void endSession() {
    dispose();
    AuthService().logout();
    Logger.info('Session ended manually');
  }
  
  /// Clean up
  void dispose() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _lastActivity = null;
  }
}

/// Widget to wrap around the app to track user interactions
class SessionTracker extends StatelessWidget {
  final Widget child;
  
  const SessionTracker({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SessionManager.instance.recordActivity(),
      onPanUpdate: (_) => SessionManager.instance.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}