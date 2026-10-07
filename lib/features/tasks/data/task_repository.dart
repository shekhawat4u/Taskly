import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/organization_settings.dart';
import '../../../shared/models/task_activity.dart';
import '../../../shared/models/task_attachment.dart';
import '../../../shared/models/task_item.dart';
import '../../../shared/models/task_priority.dart';
import '../../../shared/models/task_status.dart';

class TaskRepository {
  TaskRepository({MockDataStore? dataStore})
      : _dataStore = dataStore ?? MockDataStore.instance;

  final MockDataStore _dataStore;

  void initFirebaseSync(void Function() onUpdate) {
    _dataStore.initFirebaseSync(onUpdate);
  }

  List<TaskItem> getAllTasks() {
    return List.unmodifiable(_dataStore.tasks);
  }

  List<TaskItem> getAssignedToMe(String userId) {
    return _dataStore.tasks
        .where((t) => t.assignedToIds.contains(userId))
        .toList();
  }

  List<TaskItem> getAssignedByMe(String userId) {
    return _dataStore.tasks
        .where((t) => t.assignedById == userId)
        .toList();
  }

  List<TaskItem> getCompletedByMe(String userId) {
    return _dataStore.tasks
        .where((t) =>
            t.status == TaskStatus.completed &&
            (t.completedById == userId || t.assignedToIds.contains(userId)))
        .toList();
  }

  List<TaskItem> getCompletedAssignedByMe(String userId) {
    return _dataStore.tasks
        .where((t) => t.status == TaskStatus.completed && t.assignedById == userId)
        .toList();
  }

  TaskItem? getTaskById(String id) {
    try {
      return _dataStore.tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TaskActivity> getActivitiesForTask(String taskId) {
    return _dataStore.activities.where((a) => a.taskId == taskId).toList();
  }

  List<TaskAttachment> getAttachmentsForTask(String taskId) {
    return _dataStore.attachments.where((a) => a.taskId == taskId).toList();
  }

  HomeStats getStats(String userId) {
    return _dataStore.computeStatsForUser(userId);
  }

  TaskItem createTask({
    required String title,
    String? description,
    required List<String> assignedToIds,
    required TaskPriority priority,
    DateTime? dueDate,
    String? attachmentName,
    String? attachmentBase64,
    String? localAttachmentPath,
  }) {
    return _dataStore.createTask(
      title: title,
      description: description,
      assignedToIds: assignedToIds,
      priority: priority,
      dueDate: dueDate,
      attachmentName: attachmentName,
      attachmentBase64: attachmentBase64,
      localAttachmentPath: localAttachmentPath,
    );
  }

  TaskItem? markTaskStarted(String taskId) {
    return _dataStore.markTaskStarted(taskId);
  }

  TaskItem? markTaskCompleted(String taskId) {
    return _dataStore.markTaskCompleted(taskId);
  }

  void deleteTask(String taskId) {
    _dataStore.deleteTask(taskId);
  }

  Future<void> addSubtask(String taskId, String title) {
    return _dataStore.addSubtask(taskId, title);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) {
    return _dataStore.toggleSubtask(taskId, subtaskId);
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) {
    return _dataStore.deleteSubtask(taskId, subtaskId);
  }

  Future<void> addComment(String taskId, String text) {
    return _dataStore.addComment(taskId, text);
  }

  Future<void> deleteComment(String taskId, String commentId) {
    return _dataStore.deleteComment(taskId, commentId);
  }
}
