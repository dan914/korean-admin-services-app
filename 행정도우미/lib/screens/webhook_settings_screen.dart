import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_button.dart';
import '../ui/design_tokens.dart';
import '../models/webhook_config.dart';
import '../services/webhook_service.dart';
import '../models/lead.dart';

class WebhookSettingsScreen extends StatefulWidget {
  const WebhookSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WebhookSettingsScreen> createState() => _WebhookSettingsScreenState();
}

class _WebhookSettingsScreenState extends State<WebhookSettingsScreen> {
  final List<WebhookConfig> _webhooks = [
    // Add some example webhooks
    WebhookConfig.slack(
      webhookUrl: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK',
      channel: '#admin',
    ),
    WebhookConfig.discord(
      webhookUrl: 'https://discord.com/api/webhooks/YOUR/DISCORD/WEBHOOK',
    ),
    WebhookConfig.emailJs(
      serviceId: 'YOUR_EMAILJS_SERVICE_ID',
      templateId: 'YOUR_EMAILJS_TEMPLATE_ID',
      publicKey: 'YOUR_EMAILJS_PUBLIC_KEY',
      toEmail: 'admin@yourdomain.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('웹훅 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              children: [
                Text(
                  '알림 웹훅 관리',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: DesignTokens.spacingBase),
                Text(
                  '새로운 상담 요청이 접수될 때 알림을 받을 웹훅을 설정하세요.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: DesignTokens.spacingSection),
                
                // Webhook list
                ..._webhooks.map((webhook) => _buildWebhookCard(webhook)),
                
                SizedBox(height: DesignTokens.spacingSection),
                
                // Add new webhook button
                OutlinedButton.icon(
                  onPressed: _showAddWebhookDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('새 웹훅 추가'),
                ),
                
                SizedBox(height: DesignTokens.spacingSection),
                
                // Test webhook section
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(DesignTokens.spacingBase),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '웹훅 테스트',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: DesignTokens.spacingBase),
                        Text(
                          '활성화된 웹훅에 테스트 알림을 전송합니다.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: DesignTokens.spacingBase),
                        AppButton(
                          label: '테스트 알림 보내기',
                          onPressed: _sendTestNotification,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookCard(WebhookConfig webhook) {
    return Card(
      margin: EdgeInsets.only(bottom: DesignTokens.spacingBase),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacingBase),
        child: Row(
          children: [
            // Icon based on type
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getWebhookTypeColor(webhook.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getWebhookTypeIcon(webhook.type),
                color: _getWebhookTypeColor(webhook.type),
              ),
            ),
            SizedBox(width: DesignTokens.spacingBase),
            
            // Webhook info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    webhook.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    webhook.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (!webhook.isEnabled)
                    Text(
                      '비활성화됨',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
            
            // Toggle switch
            Switch(
              value: webhook.isEnabled,
              onChanged: (value) => _toggleWebhook(webhook, value),
            ),
            
            // More options
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text('편집'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'test',
                  child: ListTile(
                    leading: Icon(Icons.send),
                    title: Text('테스트'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('삭제'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) => _handleWebhookAction(webhook, value as String),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWebhookTypeIcon(String type) {
    switch (type) {
      case 'slack':
        return Icons.chat;
      case 'discord':
        return Icons.forum;
      case 'email':
        return Icons.email;
      default:
        return Icons.webhook;
    }
  }

  Color _getWebhookTypeColor(String type) {
    switch (type) {
      case 'slack':
        return Colors.purple;
      case 'discord':
        return Colors.indigo;
      case 'email':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _toggleWebhook(WebhookConfig webhook, bool enabled) {
    setState(() {
      final index = _webhooks.indexOf(webhook);
      if (index >= 0) {
        _webhooks[index] = webhook.copyWith(isEnabled: enabled);
      }
    });
  }

  void _handleWebhookAction(WebhookConfig webhook, String action) {
    switch (action) {
      case 'edit':
        _showEditWebhookDialog(webhook);
        break;
      case 'test':
        _testSingleWebhook(webhook);
        break;
      case 'delete':
        _deleteWebhook(webhook);
        break;
    }
  }

  void _showAddWebhookDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 웹훅 추가'),
        content: const Text('웹훅 추가 기능은 곧 제공됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showEditWebhookDialog(WebhookConfig webhook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('웹훅 편집'),
        content: Text('${webhook.name} 편집 기능은 곧 제공됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _testSingleWebhook(WebhookConfig webhook) async {
    // Create a test lead
    final testLead = Lead(
      id: 'test_lead_${DateTime.now().millisecondsSinceEpoch}',
      formData: {
        'step_1': 'relief',
        'step_2': '1010000',
        'step_4': 'penalty',
      },
      contactInfo: ContactInfo(
        name: '테스트 사용자',
        phone: '+82-10-1234-5678',
        email: 'test@example.com',
        notificationPreferences: const NotificationPreferences(
          kakao: true,
          sms: false,
          email: true,
        ),
      ),
      status: 'test',
      priority: 'low',
      source: 'webhook_test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (webhook.type == 'email') {
        await WebhookService.sendNewLeadNotification(testLead);
      } else {
        await WebhookService.sendWebhookNotification(
          webhookUrl: webhook.endpoint,
          lead: testLead,
          format: webhook.type,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${webhook.name}에 테스트 알림이 성공적으로 전송되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('죄송합니다. 테스트 알림 전송 중 오류가 발생했습니다.'),
            backgroundColor: DesignTokens.danger,
          ),
        );
      }
    }
  }

  void _deleteWebhook(WebhookConfig webhook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('웹훅 삭제 확인'),
        content: Text('${webhook.name} 웹훅을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _webhooks.remove(webhook);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: DesignTokens.danger),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() async {
    final enabledWebhooks = _webhooks.where((w) => w.isEnabled).toList();
    
    if (enabledWebhooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 활성화된 웹훅이 없습니다. 웹훅을 먼저 설정해 주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    for (final webhook in enabledWebhooks) {
      _testSingleWebhook(webhook);
    }
  }
}