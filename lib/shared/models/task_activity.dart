class TaskActivity {
  const TaskActivity({
    required this.id,
    required this.organizationId,
    required this.taskId,
    required this.userId,
    required this.action,
    required this.createdAt,
    this.metadata = const {},
    this.userName,
  });

  final String id;
  final String organizationId;
  final String taskId;
  final String userId;
  final String action;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final String? userName;

  factory TaskActivity.fromMap(Map<String, dynamic> map) {
    final user = map['profiles'];
    return TaskActivity(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      taskId: map['task_id'] as String,
      userId: map['user_id'] as String,
      action: map['action'] as String,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      metadata: (map['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      userName: user is Map<String, dynamic> ? user['name'] as String? : null,
    );
  }

  String get label {
    final name = userName ?? 'Someone';
    switch (action) {
      case 'task_created':
        return '$name created this task';
      case 'task_started':
        return '$name started this task';
      case 'task_completed':
        return '$name completed this task';
      case 'task_reopened':
        return '$name reopened this task';
      case 'due_date_changed':
        return '$name changed the due date';
      case 'priority_changed':
        return '$name changed the priority';
      case 'assignee_changed':
        return '$name changed the assignee';
      case 'description_updated':
        return '$name updated the description';
      case 'attachment_added':
        return '$name added an attachment';
      default:
        return '$name updated this task';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'task_id': taskId,
      'user_id': userId,
      'action': action,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
      'profiles': userName != null ? {'name': userName} : null,
    };
  }
}
