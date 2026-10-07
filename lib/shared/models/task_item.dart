import 'task_priority.dart';
import 'task_status.dart';
import 'user_profile.dart';
import 'subtask.dart';
import 'task_comment.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.organizationId,
    required this.title,
    this.description,
    required this.assignedById,
    required this.assignedToIds,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.completedById,
    this.isArchived = false,
    this.assignedBy,
    this.assignedTo = const [],
    this.completedBy,
    this.subtasks = const [],
    this.comments = const [],
    this.localAttachmentPath,
    this.attachmentName,
    this.attachmentBase64,
  });

  final String id;
  final String organizationId;
  final String title;
  final String? description;
  final String assignedById;
  final List<String> assignedToIds;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? completedById;
  final bool isArchived;
  final UserProfile? assignedBy;
  final List<UserProfile> assignedTo;
  final UserProfile? completedBy;
  final List<Subtask> subtasks;
  final List<TaskComment> comments;
  final String? localAttachmentPath;
  final String? attachmentName;
  final String? attachmentBase64;

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    UserProfile? profile(dynamic value) {
      if (value is Map<String, dynamic>) return UserProfile.fromMap(value);
      return null;
    }

    return TaskItem(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      assignedById: map['assigned_by'] as String,
      assignedToIds: (map['assigned_to_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: TaskStatus.fromDb(map['status'] as String? ?? 'todo'),
      priority: TaskPriority.fromDb(map['priority'] as String? ?? 'medium'),
      dueDate: DateTime.tryParse(map['due_date'] as String? ?? ''),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
      startedAt: DateTime.tryParse(map['started_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(map['completed_at'] as String? ?? ''),
      completedById: map['completed_by'] as String?,
      isArchived: map['is_archived'] as bool? ?? false,
      assignedBy: profile(map['assigned_by_profile'] ?? map['assigner']),
      assignedTo: (map['assigned_to_profiles'] as List<dynamic>?)
              ?.map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      completedBy: profile(map['completed_by_profile']),
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      comments: (map['comments'] as List<dynamic>?)
              ?.map((e) => TaskComment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      localAttachmentPath: map['local_attachment_path'] as String?,
      attachmentName: map['attachment_name'] as String?,
      attachmentBase64: map['attachment_base64'] as String?,
    );
  }

  TaskItem copyWith({
    TaskStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isArchived,
    List<Subtask>? subtasks,
    List<TaskComment>? comments,
    String? localAttachmentPath,
    String? attachmentName,
    String? attachmentBase64,
  }) {
    return TaskItem(
      id: id,
      organizationId: organizationId,
      title: title,
      description: description,
      assignedById: assignedById,
      assignedToIds: assignedToIds,
      status: status ?? this.status,
      priority: priority,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completedById: completedById,
      isArchived: isArchived ?? this.isArchived,
      assignedBy: assignedBy,
      assignedTo: assignedTo,
      completedBy: completedBy,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
      localAttachmentPath: localAttachmentPath ?? this.localAttachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentBase64: attachmentBase64 ?? this.attachmentBase64,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'assigned_by': assignedById,
      'assigned_to_ids': assignedToIds,
      'status': status.dbValue,
      'priority': priority.dbValue,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completed_by': completedById,
      'is_archived': isArchived,
      'assigned_by_profile': assignedBy?.toMap(),
      'assigned_to_profiles': assignedTo.map((e) => e.toMap()).toList(),
      'completed_by_profile': completedBy?.toMap(),
      'subtasks': subtasks.map((e) => e.toMap()).toList(),
      'comments': comments.map((e) => e.toMap()).toList(),
      'local_attachment_path': localAttachmentPath,
      'attachment_name': attachmentName,
      'attachment_base64': attachmentBase64,
    };
  }
}
