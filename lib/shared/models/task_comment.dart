class TaskComment {
  const TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'user_name': userName,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String? ?? 'User',
      text: map['text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
