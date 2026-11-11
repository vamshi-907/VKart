class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String imageUrl;
  final String type; // e.g., 'offer', 'festival', 'order_update', 'maintenance'
  final String audience; // 'customer', 'delivery_partner', 'all'
  final String priority; // 'low', 'normal', 'high'
  final bool active;
  final DateTime scheduledAt;
  final DateTime? publishedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.type,
    required this.audience,
    required this.priority,
    required this.active,
    required this.scheduledAt,
    this.publishedAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'message': message,
    'imageUrl': imageUrl,
    'type': type,
    'audience': audience,
    'priority': priority,
    'active': active,
    'scheduledAt': scheduledAt.toIso8601String(),
    if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
  };

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) => NotificationModel(
    id: id,
    title: map['title'] ?? '',
    message: map['message'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    type: map['type'] ?? 'announcement',
    audience: map['audience'] ?? 'all',
    priority: map['priority'] ?? 'normal',
    active: map['active'] ?? true,
    scheduledAt: DateTime.tryParse(map['scheduledAt'] ?? '') ?? DateTime.now(),
    publishedAt: map['publishedAt'] != null ? DateTime.tryParse(map['publishedAt']) : null,
  );
}
