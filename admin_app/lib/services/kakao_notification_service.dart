import 'dart:convert';
import 'package:http/http.dart' as http;

/// KakaoTalk AlimTalk (알림톡) Service
/// 
/// Prerequisites:
/// 1. Register at https://business.kakao.com
/// 2. Create a Kakao Channel
/// 3. Get API credentials from a provider like:
///    - Solapi (https://solapi.com)
///    - NHN Toast (https://www.toast.com)
///    - Kakao Business Direct API
class KakaoNotificationService {
  // You'll need to get these from your AlimTalk provider
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiSecret = 'YOUR_API_SECRET';
  static const String pfId = 'YOUR_PROFILE_ID'; // 발신 프로필 ID
  static const String senderId = 'YOUR_SENDER_ID'; // 발신번호
  
  // Solapi API endpoint (most popular Korean SMS/AlimTalk service)
  static const String baseUrl = 'https://api.solapi.com';
  
  /// Send AlimTalk notification
  static Future<bool> sendAlimTalk({
    required String phoneNumber,
    required String templateCode,
    required Map<String, String> variables,
  }) async {
    try {
      // Format phone number (remove dashes and spaces)
      final formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Build message from template
      final message = _buildMessageFromTemplate(templateCode, variables);
      
      // Solapi API format
      final requestBody = {
        'messages': [
          {
            'to': formattedPhone,
            'from': senderId,
            'kakaoOptions': {
              'pfId': pfId,
              'templateId': templateCode,
              'variables': variables,
            },
            'type': 'ATA', // AlimTalk type
            'text': message,
          }
        ],
      };
      
      // Create auth header (Solapi uses HMAC auth)
      final authHeader = _createAuthHeader();
      
      final response = await http.post(
        Uri.parse('$baseUrl/messages/v4/send'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        print('✅ KakaoTalk AlimTalk sent successfully');
        return true;
      } else {
        print('❌ Failed to send AlimTalk: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending AlimTalk: $e');
      return false;
    }
  }
  
  /// Create authentication header for Solapi
  static String _createAuthHeader() {
    // Solapi uses API key authentication
    // This is a simplified version - actual implementation needs HMAC-SHA256
    final credentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));
    return 'Basic $credentials';
  }
  
  /// Build message from template
  static String _buildMessageFromTemplate(String templateCode, Map<String, String> variables) {
    // Templates must be pre-registered with Kakao
    switch (templateCode) {
      case 'APPLICATION_RECEIVED':
        return '''
[행정도우미] 신청 접수 완료

안녕하세요 ${variables['name']}님,
신청이 정상적으로 접수되었습니다.

접수번호: ${variables['applicationId']}
접수일시: ${variables['date']}
처리상태: 검토중

문의: 1234-5678
        ''';
        
      case 'STATUS_CHANGED':
        return '''
[행정도우미] 처리 상태 변경

${variables['name']}님의 신청 상태가 변경되었습니다.

접수번호: ${variables['applicationId']}
변경상태: ${variables['status']}
변경일시: ${variables['date']}

자세한 내용은 홈페이지에서 확인하세요.
        ''';
        
      case 'CONSULTATION_REMINDER':
        return '''
[행정도우미] 상담 예약 알림

${variables['name']}님, 
예약하신 상담 일정을 안내드립니다.

상담일시: ${variables['consultationDate']}
상담방법: ${variables['method']}
담당자: ${variables['consultant']}

변경이 필요하신 경우 연락주세요.
문의: 1234-5678
        ''';
        
      default:
        return '알림톡 메시지';
    }
  }
  
  /// Notification templates that need to be registered with Kakao
  static const Map<String, String> templates = {
    'APPLICATION_RECEIVED': '신청 접수 완료',
    'STATUS_CHANGED': '처리 상태 변경',
    'CONSULTATION_REMINDER': '상담 예약 알림',
    'DOCUMENT_REQUEST': '추가 서류 요청',
    'PROCESSING_COMPLETE': '처리 완료',
  };
}

/// Example usage in admin panel
class NotificationExample {
  static Future<void> notifyApplicationReceived(Map<String, dynamic> application) async {
    // Only send if client opted in for Kakao notifications
    if (application['notification_kakao'] == true) {
      await KakaoNotificationService.sendAlimTalk(
        phoneNumber: application['phone'],
        templateCode: 'APPLICATION_RECEIVED',
        variables: {
          'name': application['name'],
          'applicationId': application['id'],
          'date': DateTime.now().toString(),
        },
      );
    }
  }
  
  static Future<void> notifyStatusChange(Map<String, dynamic> application, String newStatus) async {
    if (application['notification_kakao'] == true) {
      await KakaoNotificationService.sendAlimTalk(
        phoneNumber: application['phone'],
        templateCode: 'STATUS_CHANGED',
        variables: {
          'name': application['name'],
          'applicationId': application['id'],
          'status': _getStatusText(newStatus),
          'date': DateTime.now().toString(),
        },
      );
    }
  }
  
  static String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '접수 대기';
      case 'in_progress':
        return '처리중';
      case 'completed':
        return '처리 완료';
      case 'cancelled':
        return '취소됨';
      default:
        return status;
    }
  }
}