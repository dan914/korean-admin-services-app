import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApplicationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ApplicationNotifier() : super([]) {
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final applications = prefs.getStringList('applications') ?? [];
    
    state = applications.map((app) {
      return json.decode(app) as Map<String, dynamic>;
    }).toList();
  }

  Future<void> addApplication(Map<String, dynamic> application) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Add timestamp if not present
    if (!application.containsKey('timestamp')) {
      application['timestamp'] = DateTime.now().toIso8601String();
    }
    
    // Add status if not present
    if (!application.containsKey('status')) {
      application['status'] = 'pending';
    }
    
    state = [...state, application];
    
    // Save to SharedPreferences
    final applications = state.map((app) => json.encode(app)).toList();
    await prefs.setStringList('applications', applications);
  }

  Future<void> updateApplicationStatus(int index, String status) async {
    if (index < 0 || index >= state.length) return;
    
    final updatedApplications = [...state];
    updatedApplications[index] = {
      ...updatedApplications[index],
      'status': status,
    };
    
    state = updatedApplications;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final applications = state.map((app) => json.encode(app)).toList();
    await prefs.setStringList('applications', applications);
  }

  Future<void> deleteApplication(int index) async {
    if (index < 0 || index >= state.length) return;
    
    state = [...state]..removeAt(index);
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final applications = state.map((app) => json.encode(app)).toList();
    await prefs.setStringList('applications', applications);
  }

  Future<void> clearAllApplications() async {
    state = [];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applications');
  }
}

final applicationProvider = StateNotifierProvider<ApplicationNotifier, List<Map<String, dynamic>>>((ref) {
  return ApplicationNotifier();
});