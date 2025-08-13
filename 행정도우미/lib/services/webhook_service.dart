import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead.dart';
import '../utils/logger.dart';

class WebhookService {
  static const String _defaultEmailWebhook = 'https://api.emailjs.com/api/v1.0/email/send';
  
  // EmailJS configuration - you'll need to set these up
  static const String _emailjsServiceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String _emailjsTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String _emailjsPublicKey = 'YOUR_EMAILJS_PUBLIC_KEY';
  
  /// Send email notification when a new lead is submitted
  static Future<bool> sendNewLeadNotification(Lead lead) async {
    try {
      Logger.info('Sending email notification for lead: ${lead.contactInfo.name}');
      
      final emailData = {
        'service_id': _emailjsServiceId,
        'template_id': _emailjsTemplateId,
        'public_key': _emailjsPublicKey,
        'template_params': {
          'to_email': 'admin@yourdomain.com', // Replace with your email
          'lead_name': lead.contactInfo.name,
          'lead_phone': lead.contactInfo.phone,
          'lead_email': lead.contactInfo.email,
          'issue_type': _getIssueTypeText(lead.formData),
          'agency_code': lead.formData['step_2'] ?? '알 수 없음',
          'submission_time': DateTime.now().toIso8601String(),
          'admin_url': 'https://yourdomain.com/admin', // Replace with your admin URL
        }
      };
      
      final response = await http.post(
        Uri.parse(_defaultEmailWebhook),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(emailData),
      );
      
      if (response.statusCode == 200) {
        Logger.success('Email notification sent successfully');
        return true;
      } else {
        Logger.error('Failed to send email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      Logger.error('Error sending email notification: $e');
      return false;
    }
  }
  
  /// Send notification using generic webhook (for Slack, Discord, etc.)
  static Future<bool> sendWebhookNotification({
    required String webhookUrl,
    required Lead lead,
    String format = 'slack', // 'slack', 'discord', 'generic'
  }) async {
    try {
      Logger.info('Sending webhook notification to: $webhookUrl');
      
      Map<String, dynamic> payload;
      
      switch (format) {
        case 'slack':
          payload = _buildSlackPayload(lead);
          break;
        case 'discord':
          payload = _buildDiscordPayload(lead);
          break;
        default:
          payload = _buildGenericPayload(lead);
      }
      
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Logger.success('Webhook notification sent successfully');
        return true;
      } else {
        Logger.error('Failed to send webhook: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      Logger.error('Error sending webhook notification: $e');
      return false;
    }
  }
  
  /// Build Slack-formatted payload
  static Map<String, dynamic> _buildSlackPayload(Lead lead) {
    final issueType = _getIssueTypeText(lead.formData);
    final agency = lead.formData['step_2'] ?? '알 수 없음';
    
    return {
      'text': '새로운 행정 상담 요청이 접수되었습니다!',
      'attachments': [
        {
          'color': '#36a64f',
          'title': '📋 새 상담 요청',
          'fields': [
            {
              'title': '이름',
              'value': lead.contactInfo.name,
              'short': true,
            },
            {
              'title': '연락처',
              'value': lead.contactInfo.phone,
              'short': true,
            },
            {
              'title': '이메일',
              'value': lead.contactInfo.email,
              'short': true,
            },
            {
              'title': '문제 유형',
              'value': issueType,
              'short': true,
            },
            {
              'title': '관련 기관',
              'value': agency,
              'short': true,
            },
            {
              'title': '접수 시간',
              'value': DateTime.now().toString(),
              'short': true,
            },
          ],
          'footer': '행정도우미',
          'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }
      ]
    };
  }
  
  /// Build Discord-formatted payload
  static Map<String, dynamic> _buildDiscordPayload(Lead lead) {
    final issueType = _getIssueTypeText(lead.formData);
    final agency = lead.formData['step_2'] ?? '알 수 없음';
    
    return {
      'embeds': [
        {
          'title': '📋 새로운 행정 상담 요청',
          'color': 0x36a64f,
          'fields': [
            {
              'name': '이름',
              'value': lead.contactInfo.name,
              'inline': true,
            },
            {
              'name': '연락처',
              'value': lead.contactInfo.phone,
              'inline': true,
            },
            {
              'name': '이메일',
              'value': lead.contactInfo.email,
              'inline': true,
            },
            {
              'name': '문제 유형',
              'value': issueType,
              'inline': true,
            },
            {
              'name': '관련 기관',
              'value': agency,
              'inline': true,
            },
          ],
          'footer': {
            'text': '행정도우미'
          },
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]
    };
  }
  
  /// Build generic payload
  static Map<String, dynamic> _buildGenericPayload(Lead lead) {
    return {
      'event': 'new_lead',
      'data': {
        'name': lead.contactInfo.name,
        'phone': lead.contactInfo.phone,
        'email': lead.contactInfo.email,
        'issue_type': _getIssueTypeText(lead.formData),
        'agency_code': lead.formData['step_2'],
        'answers': lead.formData,
        'submitted_at': DateTime.now().toIso8601String(),
        'priority': lead.priority,
        'status': lead.status,
      }
    };
  }
  
  /// Extract human-readable issue type from wizard answers
  static String _getIssueTypeText(Map<String, dynamic> answers) {
    final step1 = answers['step_1'];
    final step4 = answers['step_4'];
    
    // Map codes to Korean text
    final issueTypes = {
      'relief': '피해 구제',
      'permit': '인허가',
      'penalty': '영업정지·과태료·허가취소',
      'support': '보조금·장려금',
      'immig': '출입국·체류',
      'appeal': '이의신청·행정심판',
      'etc': '기타',
    };
    
    final type1 = issueTypes[step1] ?? step1?.toString() ?? '알 수 없음';
    final type4 = issueTypes[step4] ?? step4?.toString() ?? '';
    
    if (type4.isNotEmpty && type4 != type1) {
      return '$type1 → $type4';
    }
    
    return type1;
  }
}