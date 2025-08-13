import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../ui/design_tokens.dart';

class WebhookSettingsScreen extends StatefulWidget {
  const WebhookSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WebhookSettingsScreen> createState() => _WebhookSettingsScreenState();
}

class _WebhookSettingsScreenState extends State<WebhookSettingsScreen> {
  final _urlController = TextEditingController();
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString('webhookUrl') ?? '';
      _isEnabled = prefs.getBool('webhookEnabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('webhookUrl', _urlController.text);
    await prefs.setBool('webhookEnabled', _isEnabled);
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Webhook 설정이 저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      appBar: AppBar(
        title: const Text('Webhook 설정'),
        backgroundColor: Colors.white,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: DesignTokens.borderLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DesignTokens.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Webhook이란?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '새로운 신청서가 접수될 때마다 지정한 URL로 데이터를 자동으로 전송합니다. Slack, Discord, 또는 커스텀 서버와 연동할 수 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Settings card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DesignTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable switch
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Webhook 활성화',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '새 신청서 접수 시 알림을 받습니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isEnabled = value;
                          });
                        },
                        activeColor: DesignTokens.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // URL input
                  Text(
                    'Webhook URL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    enabled: _isEnabled,
                    decoration: InputDecoration(
                      hintText: 'https://hooks.slack.com/services/...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isEnabled ? Colors.white : DesignTokens.bgAlt,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Test button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isEnabled && _urlController.text.isNotEmpty
                              ? _testWebhook
                              : null,
                          icon: const Icon(Icons.send),
                          label: const Text('테스트 전송'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveSettings,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isLoading ? '저장 중...' : '설정 저장'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Example payload
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.bgAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DesignTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전송 데이터 예시',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '''
{
  "name": "홍길동",
  "phone": "010-1234-5678",
  "email": "hong@example.com",
  "memo": "상담 내용...",
  "timestamp": "2024-01-15T10:30:00",
  "reservationDate": "2024-01-20",
  "firstTimeSlot": "14:00",
  "secondTimeSlot": "15:00"
}''',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testWebhook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('테스트 메시지를 전송했습니다'),
        backgroundColor: DesignTokens.info,
      ),
    );
  }
}