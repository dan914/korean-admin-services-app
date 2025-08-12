import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wizard_provider.dart';

class DraftService {
  static const String _draftKey = 'wizard_draft';
  static const String _draftIdKey = 'draft_id';

  static Future<void> saveDraft(WizardState state) async {
    final prefs = await SharedPreferences.getInstance();
    
    final draftData = {
      'currentStepId': state.currentStepId,
      'answers': state.answers,
      'stepHistory': state.stepHistory,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(_draftKey, jsonEncode(draftData));
    
    // Generate or get draft ID for deep linking
    String? draftId = prefs.getString(_draftIdKey);
    if (draftId == null) {
      draftId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_draftIdKey, draftId);
    }
  }

  static Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(_draftKey);
    
    if (draftJson != null) {
      return jsonDecode(draftJson) as Map<String, dynamic>;
    }
    
    return null;
  }

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    await prefs.remove(_draftIdKey);
  }

  static Future<String?> getDraftId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_draftIdKey);
  }
}

// Provider for auto-save functionality
final autoSaveProvider = Provider<void>((ref) {
  // Listen to wizard state changes
  ref.listen<WizardState>(wizardProvider, (previous, next) {
    // Save draft whenever state changes
    if (previous?.answers != next.answers || 
        previous?.currentStepId != next.currentStepId) {
      DraftService.saveDraft(next);
    }
  });
});

// Provider to load draft on app start
final draftLoaderProvider = FutureProvider<bool>((ref) async {
  final draft = await DraftService.loadDraft();
  
  if (draft != null) {
    // Check if draft is less than 7 days old
    final lastUpdated = DateTime.parse(draft['lastUpdated'] as String);
    final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;
    
    if (daysSinceUpdate < 7) {
      ref.read(wizardProvider.notifier).loadDraft(draft);
      return true;
    } else {
      // Clear old draft
      await DraftService.clearDraft();
    }
  }
  
  return false;
});