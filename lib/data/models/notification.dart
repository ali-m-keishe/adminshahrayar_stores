class NotificationModel {
  final String? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? sentAt;
  final bool isSent;

  const NotificationModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.sentAt,
    this.isSent = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : null,
      isSent: json['is_sent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      if (sentAt != null) 'sent_at': sentAt!.toIso8601String(),
      'is_sent': isSent,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? sentAt,
    bool? isSent,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      isSent: isSent ?? this.isSent,
    );
  }
}

