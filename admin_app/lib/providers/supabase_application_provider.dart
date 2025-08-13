import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider for applications from Supabase
final supabaseApplicationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getApplications();
});

// Provider for filtered applications
final filteredApplicationsProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, status) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getApplications(status: status == 'all' ? null : status);
});

// Provider for statistics
final applicationStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getStatistics();
});

// Notifier for managing application state
class ApplicationStateNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SupabaseService _service;
  
  ApplicationStateNotifier(this._service) : super(const AsyncValue.loading()) {
    loadApplications();
  }
  
  Future<void> loadApplications() async {
    state = const AsyncValue.loading();
    try {
      final applications = await _service.getApplications();
      state = AsyncValue.data(applications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateStatus(String id, String status) async {
    await _service.updateApplicationStatus(id, status);
    await _service.addAuditEntry(
      applicationId: id,
      action: 'status_updated',
      changes: {'status': status},
    );
    await loadApplications(); // Reload data
  }
  
  Future<void> deleteApplication(String id) async {
    await _service.deleteApplication(id);
    await loadApplications(); // Reload data
  }
}

// Provider for application state management
final applicationStateProvider = StateNotifierProvider<ApplicationStateNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return ApplicationStateNotifier(service);
});