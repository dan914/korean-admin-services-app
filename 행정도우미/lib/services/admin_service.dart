import '../services/supabase_service.dart';
import '../models/lead.dart';
import '../config/env.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final _supabase = SupabaseService();

  /// Get all leads with optional filtering
  Future<List<Lead>> getLeads({
    String? status,
    String? priority,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    if (!Env.isConfigured) {
      // Return mock data for offline mode
      return _getMockLeads();
    }

    try {
      final result = await _supabase.getLeads(
        status: status == 'all' ? null : status,
        limit: limit,
        offset: offset,
      );
      
      return result.map((json) => Lead.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  /// Get lead statistics for dashboard
  Future<Map<String, dynamic>> getLeadStats() async {
    if (!Env.isConfigured) {
      return _getMockStats();
    }

    try {
      // For now, let's get all leads and calculate stats in memory
      // This can be optimized later with SQL aggregation functions
      final allLeads = await _supabase.getLeads(limit: 1000);
      
      final statusCounts = <String, int>{};
      final priorityCounts = <String, int>{};
      
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      int recentCount = 0;
      
      for (final lead in allLeads) {
        // Count by status
        final status = lead['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        
        // Count by priority
        final priority = lead['priority'] as String;
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
        
        // Count recent leads
        final createdAt = DateTime.parse(lead['created_at']);
        if (createdAt.isAfter(weekAgo)) {
          recentCount++;
        }
      }

      return {
        'total': allLeads.length,
        'pending': statusCounts['pending'] ?? 0,
        'in_progress': statusCounts['in_progress'] ?? 0,
        'completed': statusCounts['completed'] ?? 0,
        'cancelled': statusCounts['cancelled'] ?? 0,
        'recent_week': recentCount,
        'priority_counts': priorityCounts,
        'status_counts': statusCounts,
      };
    } catch (e) {
      throw Exception('Failed to fetch lead statistics: $e');
    }
  }

  /// Update lead status
  Future<Lead> updateLeadStatus(String leadId, String newStatus) async {
    if (!Env.isConfigured) {
      throw Exception('Supabase not configured for admin operations');
    }

    try {
      final result = await _supabase.updateLeadStatus(
        leadId: leadId,
        status: newStatus,
      );
      
      return Lead.fromJson(result);
    } catch (e) {
      throw Exception('Failed to update lead status: $e');
    }
  }

  /// Get single lead with full details
  Future<Lead?> getLeadById(String leadId) async {
    if (!Env.isConfigured) {
      final mockLeads = _getMockLeads();
      try {
        return mockLeads.firstWhere((lead) => lead.id == leadId);
      } catch (e) {
        return null;
      }
    }

    try {
      final allLeads = await _supabase.getLeads();
      final leadData = allLeads.where((lead) => lead['id'] == leadId).first;
      return Lead.fromJson(leadData);
    } catch (e) {
      return null;
    }
  }

  /// Get audit trail for a lead
  Future<List<Map<String, dynamic>>> getLeadAuditTrail(String leadId) async {
    if (!Env.isConfigured) {
      return _getMockAuditTrail();
    }

    try {
      return await _supabase.getAuditTrail(leadId);
    } catch (e) {
      throw Exception('Failed to fetch audit trail: $e');
    }
  }

  // Mock data for offline testing
  List<Lead> _getMockLeads() {
    return [
      Lead(
        id: 'mock-1',
        formData: {
          'step_1': 'relief',
          'step_2': '1120000',
          'step_3': 'notice',
          'step_4': 'penalty',
          'step_5': '1',
          'step_6': '2',
          'step_7': '11',
          'step_8': 'week',
          'step_9': 'phone',
          'step_10': 'fair',
        },
        contactInfo: const ContactInfo(
          name: '홍길동',
          phone: '010-1234-5678',
          email: 'hong@example.com',
          notificationPreferences: NotificationPreferences(
            kakao: true,
            sms: false,
            email: true,
          ),
        ),
        status: 'pending',
        priority: 'normal',
        source: 'web_form',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Lead(
        id: 'mock-2',
        formData: {
          'step_1': 'support',
          'step_2': '1010000',
          'step_3': 'unknown',
          'step_4': 'support',
          'step_5': '2',
          'step_6': '3',
          'step_7': '31',
          'step_8': 'day',
          'step_9': 'email',
          'step_10': 'urgent',
        },
        contactInfo: const ContactInfo(
          name: '김영희',
          phone: '010-9876-5432',
          email: 'kim@example.com',
          notificationPreferences: NotificationPreferences(
            kakao: false,
            sms: true,
            email: true,
          ),
        ),
        status: 'in_progress',
        priority: 'high',
        source: 'web_form',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Lead(
        id: 'mock-3',
        formData: {
          'step_1': 'permit',
          'step_2': '2010000',
          'step_3': 'rejected',
          'step_4': 'permit',
          'step_5': '3',
          'step_6': '1',
          'step_7': '11',
          'step_8': 'month',
          'step_9': 'visit',
          'step_10': 'low',
        },
        contactInfo: const ContactInfo(
          name: '박철수',
          phone: '010-5555-1234',
          email: 'park@example.com',
          notificationPreferences: NotificationPreferences(
            kakao: true,
            sms: true,
            email: false,
          ),
        ),
        status: 'completed',
        priority: 'low',
        source: 'web_form',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Map<String, dynamic> _getMockStats() {
    return {
      'total': 25,
      'pending': 12,
      'in_progress': 8,
      'completed': 4,
      'cancelled': 1,
      'recent_week': 15,
      'priority_counts': {'high': 5, 'normal': 18, 'low': 2},
      'status_counts': {'pending': 12, 'in_progress': 8, 'completed': 4, 'cancelled': 1},
    };
  }

  List<Map<String, dynamic>> _getMockAuditTrail() {
    return [
      {
        'action': 'lead_created',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'changes': {'status': 'pending'},
      },
      {
        'action': 'status_updated',
        'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'changes': {'status': 'in_progress'},
      },
    ];
  }
}