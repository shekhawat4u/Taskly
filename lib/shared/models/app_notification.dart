import 'notification_type.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.organizationId,
    required this.userId,
    this.taskId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String userId;
  final String? taskId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({
    String? id,
    String? organizationId,
    String? userId,
    String? taskId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      userId: map['user_id'] as String,
      taskId: map['task_id'] as String?,
      type: NotificationType.fromDb(map['type'] as String? ?? 'task_assigned'),
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      isRead: map['is_read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'task_id': taskId,
      'type': type.dbValue,
      'title': title,
      'message': message,
      'is_read': isRead,
      'push_sent': false,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
