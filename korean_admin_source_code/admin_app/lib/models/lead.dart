class Lead {
  final String id;
  final Map<String, dynamic> formData;
  final ContactInfo contactInfo;
  final String status;
  final String priority;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sessionId;

  const Lead({
    required this.id,
    required this.formData,
    required this.contactInfo,
    required this.status,
    required this.priority,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.sessionId,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      formData: Map<String, dynamic>.from(json['form_data']),
      contactInfo: ContactInfo.fromJson(json['contact_info']),
      status: json['status'],
      priority: json['priority'],
      source: json['source'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_data': formData,
      'contact_info': contactInfo.toJson(),
      'status': status,
      'priority': priority,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'session_id': sessionId,
    };
  }

  Lead copyWith({
    String? status,
    String? priority,
    Map<String, dynamic>? formData,
    ContactInfo? contactInfo,
  }) {
    return Lead(
      id: id,
      formData: formData ?? this.formData,
      contactInfo: contactInfo ?? this.contactInfo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      source: source,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sessionId: sessionId,
    );
  }
}

class ContactInfo {
  final String name;
  final String phone;
  final String email;
  final NotificationPreferences notificationPreferences;

  const ContactInfo({
    required this.name,
    required this.phone,
    required this.email,
    required this.notificationPreferences,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      notificationPreferences: NotificationPreferences.fromJson(
        json['notification_preferences'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'notification_preferences': notificationPreferences.toJson(),
    };
  }
}

class NotificationPreferences {
  final bool kakao;
  final bool sms;
  final bool email;

  const NotificationPreferences({
    required this.kakao,
    required this.sms,
    required this.email,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      kakao: json['kakao'] ?? false,
      sms: json['sms'] ?? false,
      email: json['email'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kakao': kakao,
      'sms': sms,
      'email': email,
    };
  }
}