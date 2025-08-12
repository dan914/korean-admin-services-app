class WebhookConfig {
  final String id;
  final String name;
  final String type; // 'email', 'slack', 'discord', 'generic'
  final String endpoint;
  final Map<String, String> settings;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const WebhookConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.endpoint,
    required this.settings,
    required this.isEnabled,
    required this.createdAt,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'endpoint': endpoint,
      'settings': settings,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'last_used': lastUsed?.toIso8601String(),
    };
  }

  factory WebhookConfig.fromJson(Map<String, dynamic> json) {
    return WebhookConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      endpoint: json['endpoint'] as String,
      settings: Map<String, String>.from(json['settings'] ?? {}),
      isEnabled: json['is_enabled'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsed: json['last_used'] != null 
          ? DateTime.parse(json['last_used'] as String) 
          : null,
    );
  }

  WebhookConfig copyWith({
    String? id,
    String? name,
    String? type,
    String? endpoint,
    Map<String, String>? settings,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return WebhookConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      settings: settings ?? this.settings,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  // Predefined webhook configurations
  static WebhookConfig emailJs({
    required String serviceId,
    required String templateId,
    required String publicKey,
    required String toEmail,
  }) {
    return WebhookConfig(
      id: 'emailjs_${DateTime.now().millisecondsSinceEpoch}',
      name: 'EmailJS 알림',
      type: 'email',
      endpoint: 'https://api.emailjs.com/api/v1.0/email/send',
      settings: {
        'service_id': serviceId,
        'template_id': templateId,
        'public_key': publicKey,
        'to_email': toEmail,
      },
      isEnabled: true,
      createdAt: DateTime.now(),
    );
  }

  static WebhookConfig slack({
    required String webhookUrl,
    String? channel,
  }) {
    return WebhookConfig(
      id: 'slack_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Slack 알림',
      type: 'slack',
      endpoint: webhookUrl,
      settings: {
        if (channel != null) 'channel': channel,
      },
      isEnabled: true,
      createdAt: DateTime.now(),
    );
  }

  static WebhookConfig discord({
    required String webhookUrl,
  }) {
    return WebhookConfig(
      id: 'discord_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Discord 알림',
      type: 'discord',
      endpoint: webhookUrl,
      settings: {},
      isEnabled: true,
      createdAt: DateTime.now(),
    );
  }
}