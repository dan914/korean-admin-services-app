import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import 'auth_service.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    
    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Get all applications with optional filtering
  Future<List<Map<String, dynamic>>> getApplications({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Check if user is authenticated
      final authService = AuthService();
      if (!authService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await client
          .from('applications')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // Filter in-memory for now (can optimize later)
      List<Map<String, dynamic>> applications = List<Map<String, dynamic>>.from(response);
      
      if (status != null && status != 'all') {
        applications = applications.where((app) => app['status'] == status).toList();
      }
      
      return applications;
    } on PostgrestException catch (e) {
      print('Database error fetching applications: ${e.message}');
      if (e.code == '42501' || e.message.contains('RLS')) {
        throw Exception('Access denied. Please ensure you are logged in with proper permissions.');
      }
      throw Exception('Failed to fetch applications: ${e.message}');
    } catch (e) {
      print('Error fetching applications: $e');
      if (e.toString().contains('not authenticated')) {
        throw e;
      }
      throw Exception('Failed to fetch applications: $e');
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(String id, String status) async {
    try {
      // Check if user is authenticated
      final authService = AuthService();
      if (!authService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      await client
          .from('applications')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } on PostgrestException catch (e) {
      print('Database error updating application: ${e.message}');
      if (e.code == '42501' || e.message.contains('RLS')) {
        throw Exception('Access denied. Please ensure you are logged in with proper permissions.');
      }
      throw Exception('Failed to update application: ${e.message}');
    } catch (e) {
      print('Error updating application status: $e');
      throw e;
    }
  }

  // Delete application
  Future<void> deleteApplication(String id) async {
    try {
      // Check if user is authenticated
      final authService = AuthService();
      if (!authService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      await client
          .from('applications')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      print('Database error deleting application: ${e.message}');
      if (e.code == '42501' || e.message.contains('RLS')) {
        throw Exception('Access denied. Please ensure you are logged in with proper permissions.');
      }
      throw Exception('Failed to delete application: ${e.message}');
    } catch (e) {
      print('Error deleting application: $e');
      throw e;
    }
  }

  // Get application statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      // Check if user is authenticated
      final authService = AuthService();
      if (!authService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await client
          .from('application_stats')
          .select()
          .single();
      
      return {
        'total': response['total_applications'] ?? 0,
        'pending': response['pending_count'] ?? 0,
        'in_progress': response['in_progress_count'] ?? 0,
        'completed': response['completed_count'] ?? 0,
        'cancelled': response['cancelled_count'] ?? 0,
        'recent_week': response['last_week_count'] ?? 0,
      };
    } on PostgrestException catch (e) {
      print('Database error fetching statistics: ${e.message}');
      if (e.code == '42501' || e.message.contains('RLS')) {
        print('RLS policy blocking statistics access - returning zeros');
      }
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
        'recent_week': 0,
      };
    } catch (e) {
      print('Error fetching statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
        'recent_week': 0,
      };
    }
  }

  // Add audit trail entry
  Future<void> addAuditEntry({
    required String applicationId,
    required String action,
    Map<String, dynamic>? changes,
  }) async {
    try {
      // Check if user is authenticated
      final authService = AuthService();
      if (!authService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      await client.from('audit_trail').insert({
        'application_id': applicationId,
        'action': action,
        'changes': changes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      print('Database error adding audit entry: ${e.message}');
    } catch (e) {
      print('Error adding audit entry: $e');
    }
  }
}