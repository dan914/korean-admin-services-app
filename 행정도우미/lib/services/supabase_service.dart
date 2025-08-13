import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  Future<Map<String, dynamic>> submitLead({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> contactInfo,
  }) async {
    print('📤 Starting Supabase submission...');
    print('📤 Form data: $formData');
    print('📤 Contact info: $contactInfo');
    
    try {
      // Process documents if they exist
      final documents = formData['documents'] as List<PlatformFile>?;
      List<Map<String, dynamic>>? documentInfo;
      
      if (documents != null && documents.isNotEmpty) {
        documentInfo = documents.map((file) => {
          'name': file.name,
          'size': file.size,
          'extension': file.name.split('.').last.toLowerCase(),
        }).toList();
      }
      
      // Remove PlatformFile objects and replace with document info
      final processedFormData = Map<String, dynamic>.from(formData);
      if (documentInfo != null) {
        processedFormData['documents'] = documentInfo;
      } else {
        processedFormData.remove('documents');
      }
      
      // Extract key fields from form data for direct columns
      // The wizard uses step_1, step_2, etc. for storing answers
      // Map wizard steps to business fields
      final businessType = formData['step_1'] ?? '';  // Purpose/목적
      final businessName = contactInfo['name'] ?? '';  // Use contact name as business name
      final serviceType = formData['step_4'] ?? '';  // Service type/사안 종류
      final description = formData['memo'] ?? '';
      final urgency = formData['step_3'] == 'notice' || formData['step_3'] == 'rejected' ? 'urgent' : 'normal';
      final budget = '';  // Not collected in the wizard
      final location = formData['step_5'] ?? '';  // Region/지역
      final agencyCode = formData['step_2'] ?? '';  // Agency/기관
      
      final response = await client
          .from('applications')
          .insert({
            'form_data': processedFormData,
            'name': contactInfo['name'],
            'phone': contactInfo['phone'],
            'email': contactInfo['email'],
            // Add extracted business fields
            'business_type': businessType,
            'business_name': businessName,
            'service_type': serviceType,
            'description': description,
            'urgency': urgency,
            'budget': budget,
            'location': location,
            'documents': documentInfo,
            // Notification preferences
            'notification_kakao': contactInfo['notification_preferences']?['kakao'] ?? false,
            'notification_sms': contactInfo['notification_preferences']?['sms'] ?? false,
            'notification_email': contactInfo['notification_preferences']?['email'] ?? false,
            'status': 'pending',
            'priority': urgency == 'urgent' ? 'high' : 'normal',
            'source': 'web_form',
          })
          .select()
          .single();

      // Create audit trail entry
      await _createAuditTrail(
        leadId: response['id'],
        action: 'lead_created',
        changes: {
          'form_data': processedFormData,
          'contact_info': contactInfo,
        },
      );

      return response;
    } catch (e) {
      print('❌ Supabase error details: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('Failed to submit lead: $e');
    }
  }

  Future<void> _createAuditTrail({
    required String leadId,
    required String action,
    required Map<String, dynamic> changes,
  }) async {
    try {
      // Get previous hash if exists
      final previousAudit = await client
          .from('audit_trail')
          .select('hash')
          .eq('lead_id', leadId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final prevHash = previousAudit?['hash'] ?? '';

      // Create hash of current entry
      final dataToHash = {
        'lead_id': leadId,
        'action': action,
        'changes': changes,
        'prev_hash': prevHash,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final bytes = utf8.encode(jsonEncode(dataToHash));
      final hash = sha256.convert(bytes).toString();

      await client.from('audit_trail').insert({
        'lead_id': leadId,
        'action': action,
        'changes': changes,
        'hash': hash,
        'prev_hash': prevHash.isEmpty ? null : prevHash,
      });
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to create audit trail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeads({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = client
          .from('applications')
          .select();
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final result = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return result;
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  Future<Map<String, dynamic>> updateLeadStatus({
    required String leadId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        if (additionalData != null) ...additionalData,
      };

      final response = await client
          .from('applications')
          .update(updateData)
          .eq('id', leadId)
          .select()
          .single();

      // Create audit trail
      await _createAuditTrail(
        leadId: leadId,
        action: 'status_updated',
        changes: updateData,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update lead status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAuditTrail(String leadId) async {
    try {
      return await client
          .from('audit_trail')
          .select()
          .eq('lead_id', leadId)
          .order('created_at', ascending: true);
    } catch (e) {
      throw Exception('Failed to fetch audit trail: $e');
    }
  }
}