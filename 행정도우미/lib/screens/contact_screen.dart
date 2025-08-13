import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_button.dart';
import '../widgets/step_card.dart';
import '../ui/design_tokens.dart';
import '../providers/wizard_provider.dart';
import '../services/supabase_service.dart';
import '../models/lead.dart';
import '../config/env.dart';

class ContactFormData {
  String name = '';
  String phone = '';
  String email = '';
  bool allowKakao = false;
  bool allowSms = false;
  bool allowEmail = false;
}

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = ContactFormData();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처 정보'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DesignTokens.spacingBase),
                child: Column(
                  children: [
                    StepCard(
                      stepNumber: '✉️',
                      title: '연락처 정보',
                      subtitle: '상담 결과를 받으실 연락처를 입력해주세요',
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '이름',
                              hintText: '홍길동',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '성함을 입력해 주시기 바랍니다';
                              }
                              return null;
                            },
                            onSaved: (value) => _formData.name = value ?? '',
                          ),
                          SizedBox(height: DesignTokens.spacingBase),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '휴대폰 번호',
                              hintText: '010-1234-5678',
                              prefixText: '+82 ',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '휴대폰 번호를 입력해 주시기 바랍니다';
                              }
                              // Remove non-digits and check format
                              final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digits.length < 10 || digits.length > 11) {
                                return '올바른 휴대폰 번호 형식으로 입력해 주세요';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              final digits = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                              _formData.phone = '+82${digits.startsWith('0') ? digits.substring(1) : digits}';
                            },
                          ),
                          SizedBox(height: DesignTokens.spacingBase),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              hintText: 'example@email.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이메일 주소를 입력해 주시기 바랍니다';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return '올바른 이메일 형식으로 입력해 주세요';
                              }
                              return null;
                            },
                            onSaved: (value) => _formData.email = value ?? '',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacingSection),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(DesignTokens.spacingBase),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '알림 수신 동의',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: DesignTokens.spacingBase),
                            _buildNotificationOption(
                              '카카오톡 알림',
                              '카카오 비즈메시지로 상담 결과를 받습니다',
                              _formData.allowKakao,
                              (value) => setState(() => _formData.allowKakao = value ?? false),
                            ),
                            Divider(height: DesignTokens.spacingSection),
                            _buildNotificationOption(
                              'SMS 알림',
                              '문자메시지로 상담 결과를 받습니다',
                              _formData.allowSms,
                              (value) => setState(() => _formData.allowSms = value ?? false),
                            ),
                            Divider(height: DesignTokens.spacingSection),
                            _buildNotificationOption(
                              '이메일 알림',
                              '이메일로 상담 결과를 받습니다',
                              _formData.allowEmail,
                              (value) => setState(() => _formData.allowEmail = value ?? false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              decoration: BoxDecoration(
                color: DesignTokens.bgAlt,
                border: Border(
                  top: BorderSide(color: DesignTokens.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '* 원활한 상담을 위해 최소 1개 이상의 알림 수신에 동의해 주시기 바랍니다',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: DesignTokens.danger,
                        ),
                  ),
                  SizedBox(height: DesignTokens.spacingBase),
                  AppButton(
                    label: '제출하기',
                    isLoading: _isSubmitting,
                    onPressed: (_formData.allowKakao || _formData.allowSms || _formData.allowEmail)
                        ? _submitForm
                        : null,
                  ),
                  SizedBox(height: DesignTokens.spacingBase),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: DesignTokens.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    print('🚀 Submit form called');
    setState(() => _errorMessage = null);
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      setState(() => _errorMessage = '모든 필수 항목을 입력해주세요.');
      return;
    }

    _formKey.currentState!.save();
    print('✅ Form validated and saved');
    print('Contact Info: Name=${_formData.name}, Phone=${_formData.phone}, Email=${_formData.email}');

    setState(() => _isSubmitting = true);

    try {
      // Get wizard state
      final wizardState = ref.read(wizardProvider);
      print('📋 Wizard state: ${wizardState.answers}');
      
      // Create lead object for webhooks
      final leadData = Lead(
        id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
        formData: wizardState.answers,
        contactInfo: ContactInfo(
          name: _formData.name,
          phone: _formData.phone,
          email: _formData.email,
          notificationPreferences: NotificationPreferences(
            kakao: _formData.allowKakao,
            sms: _formData.allowSms,
            email: _formData.allowEmail,
          ),
        ),
        status: 'new',
        priority: 'medium',
        source: 'web',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (Env.isConfigured) {
        // Submit to Supabase
        await SupabaseService().submitLead(
          formData: wizardState.answers,
          contactInfo: {
            'name': _formData.name,
            'phone': _formData.phone,
            'email': _formData.email,
            'notification_preferences': {
              'kakao': _formData.allowKakao,
              'sms': _formData.allowSms,
              'email': _formData.allowEmail,
            },
          },
        );
      } else {
        // Offline mode - just simulate submission
        print('📧 Lead submission (offline mode):');
        print('Form Data: ${wizardState.answers}');
        print('Contact: ${_formData.name}, ${_formData.phone}, ${_formData.email}');
        print('Notifications: Kakao=${_formData.allowKakao}, SMS=${_formData.allowSms}, Email=${_formData.allowEmail}');
        await Future.delayed(const Duration(seconds: 1));
      }

      // Send webhook notifications (works in both online and offline modes)
      print('🔔 Sending webhook notifications...');
      _sendWebhookNotifications(leadData);

      print('✅ Form submission successful, navigating to success');
      if (mounted) {
        context.go('/success');
      }
    } catch (e) {
      print('❌ Form submission error: $e');
      setState(() => _errorMessage = '제출 중 오류가 발생했습니다: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('죄송합니다. 제출 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'),
            backgroundColor: DesignTokens.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Send webhook notifications for new lead submission
  void _sendWebhookNotifications(Lead lead) async {
    try {
      // For demo purposes, let's try a test webhook URL (you can use webhook.site for testing)
      // Replace with your actual webhook URLs

      // Example: Send to a generic webhook (could be Zapier, n8n, etc.)
      final testWebhookUrl = 'https://webhook.site/your-unique-id'; // Replace with your test URL
      
      // You can uncomment this to test with a real webhook URL:
      // await WebhookService.sendWebhookNotification(
      //   webhookUrl: testWebhookUrl,
      //   lead: lead,
      //   format: 'generic',
      // );

      // Example: Send Slack notification
      // const slackWebhookUrl = 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK';
      // await WebhookService.sendWebhookNotification(
      //   webhookUrl: slackWebhookUrl,
      //   lead: lead,
      //   format: 'slack',
      // );

      // Example: Send Discord notification
      // const discordWebhookUrl = 'https://discord.com/api/webhooks/YOUR/WEBHOOK';
      // await WebhookService.sendWebhookNotification(
      //   webhookUrl: discordWebhookUrl,
      //   lead: lead,
      //   format: 'discord',
      // );

      // For now, just log the notification data
      print('🔔 Webhook notification data prepared:');
      print('Name: ${lead.contactInfo.name}');
      print('Email: ${lead.contactInfo.email}');
      print('Phone: ${lead.contactInfo.phone}');
      print('Issue Type: ${_getIssueTypeFromFormData(lead.formData)}');
      
      // Simulate webhook success
      print('✅ Webhook notifications sent (simulated)');
      
    } catch (e) {
      print('❌ Failed to send webhook notifications: $e');
      // Don't fail the entire submission if webhooks fail
    }
  }

  /// Extract issue type from form data for display
  String _getIssueTypeFromFormData(Map<String, dynamic> formData) {
    final step1 = formData['step_1'];
    final step4 = formData['step_4'];
    
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