import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

class ApplicationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final SupabaseService _supabaseService = SupabaseService();
  
  ApplicationNotifier() : super([]) {
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      final applications = await _supabaseService.getApplications();
      state = applications;
    } catch (e) {
      Logger.debug('Error loading applications: $e');
      state = [];
    }
  }

  Future<void> addApplication(Map<String, dynamic> application) async {
    // Add timestamp if not present
    if (!application.containsKey('created_at')) {
      application['created_at'] = DateTime.now().toIso8601String();
    }
    
    // Add status if not present
    if (!application.containsKey('status')) {
      application['status'] = 'pending';
    }
    
    // Note: This would typically be done by the main app submitting to Supabase
    // The admin app primarily reads data
    await _loadApplications();
  }

  Future<void> updateApplicationStatus(int index, String status) async {
    if (index < 0 || index >= state.length) return;
    
    try {
      final application = state[index];
      final id = application['id']?.toString();
      
      if (id != null) {
        await _supabaseService.updateApplicationStatus(id, status);
        await _loadApplications(); // Refresh the data
      }
    } catch (e) {
      Logger.debug('Error updating application status: $e');
    }
  }

  Future<void> deleteApplication(int index) async {
    if (index < 0 || index >= state.length) return;
    
    try {
      final application = state[index];
      final id = application['id']?.toString();
      
      if (id != null) {
        await _supabaseService.deleteApplication(id);
        await _loadApplications(); // Refresh the data
      }
    } catch (e) {
      Logger.debug('Error deleting application: $e');
    }
  }

  Future<void> clearAllApplications() async {
    // This would require a bulk delete operation
    // For now, just refresh the data
    await _loadApplications();
  }
  
  // Add a refresh method to manually reload data
  Future<void> refresh() async {
    await _loadApplications();
  }
}

final applicationProvider = StateNotifierProvider<ApplicationNotifier, List<Map<String, dynamic>>>((ref) {
  return ApplicationNotifier();
});