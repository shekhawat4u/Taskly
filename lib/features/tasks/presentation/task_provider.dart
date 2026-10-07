import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/due_date.dart';
import '../../../shared/models/organization_settings.dart';
import '../../../shared/models/task_activity.dart';
import '../../../shared/models/task_attachment.dart';
import '../../../shared/models/task_item.dart';
import '../../../shared/models/task_priority.dart';
import '../../../shared/models/task_status.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repo = TaskRepository();
  repo.initFirebaseSync(() {
    ref.read(taskStateRevisionProvider.notifier).state++;
  });
  return repo;
});

final taskStateRevisionProvider = StateProvider<int>((ref) => 0);

final allTasksProvider = Provider<List<TaskItem>>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAllTasks();
});

final homeStatsProvider = Provider<HomeStats>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) {
    return const HomeStats(
      assignedToMe: 0,
      dueToday: 0,
      inProgress: 0,
      completedThisWeek: 0,
    );
  }
  return repo.getStats(currentUser.id);
});

final assignedToMeTasksProvider = Provider<List<TaskItem>>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return [];
  return repo.getAssignedToMe(currentUser.id);
});

final assignedByMeTasksProvider = Provider<List<TaskItem>>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return [];
  return repo.getAssignedByMe(currentUser.id);
});

final completedByMeTasksProvider = Provider<List<TaskItem>>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return [];
  return repo.getCompletedByMe(currentUser.id);
});

final completedAssignedByMeTasksProvider = Provider<List<TaskItem>>((ref) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return [];
  return repo.getCompletedAssignedByMe(currentUser.id);
});

final taskDetailProvider = Provider.family<TaskItem?, String>((ref, taskId) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTaskById(taskId);
});

final taskActivitiesProvider =
    Provider.family<List<TaskActivity>, String>((ref, taskId) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getActivitiesForTask(taskId);
});

final taskAttachmentsProvider =
    Provider.family<List<TaskAttachment>, String>((ref, taskId) {
  ref.watch(taskStateRevisionProvider);
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAttachmentsForTask(taskId);
});

class TaskNotifier {
  TaskNotifier(this.ref);
  final Ref ref;

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
    final repo = ref.read(taskRepositoryProvider);
    final created = repo.createTask(
      title: title,
      description: description,
      assignedToIds: assignedToIds,
      priority: priority,
      dueDate: dueDate,
      attachmentName: attachmentName,
      attachmentBase64: attachmentBase64,
      localAttachmentPath: localAttachmentPath,
    );
    ref.read(taskStateRevisionProvider.notifier).state++;
    return created;
  }

  void markStarted(String taskId) {
    final repo = ref.read(taskRepositoryProvider);
    repo.markTaskStarted(taskId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  void markCompleted(String taskId) {
    final repo = ref.read(taskRepositoryProvider);
    repo.markTaskCompleted(taskId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  void deleteTask(String taskId) {
    final repo = ref.read(taskRepositoryProvider);
    repo.deleteTask(taskId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  Future<void> addSubtask(String taskId, String title) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.addSubtask(taskId, title);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleSubtask(taskId, subtaskId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteSubtask(taskId, subtaskId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  Future<void> addComment(String taskId, String text) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.addComment(taskId, text);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }

  Future<void> deleteComment(String taskId, String commentId) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteComment(taskId, commentId);
    ref.read(taskStateRevisionProvider.notifier).state++;
  }
}

final taskNotifierProvider = Provider<TaskNotifier>((ref) {
  return TaskNotifier(ref);
});

// Search & Filter state for TasksScreen
final taskFilterStatusProvider = StateProvider<TaskStatusFilter>((ref) => TaskStatusFilter.all);
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAssignedToMeTasksProvider = Provider<List<TaskItem>>((ref) {
  final all = ref.watch(assignedToMeTasksProvider);
  final filter = ref.watch(taskFilterStatusProvider);
  final query = ref.watch(taskSearchQueryProvider).trim().toLowerCase();

  return all.where((task) {
    // Search query filter
    if (query.isNotEmpty) {
      final matchTitle = task.title.toLowerCase().contains(query);
      final matchDesc = (task.description ?? '').toLowerCase().contains(query);
      final matchAssignee = task.assignedTo.any((a) => a.name.toLowerCase().contains(query));
      final matchAssigner = (task.assignedBy?.name ?? '').toLowerCase().contains(query);
      if (!matchTitle && !matchDesc && !matchAssignee && !matchAssigner) return false;
    }

    // Status filter
    switch (filter) {
      case TaskStatusFilter.all:
        return true;
      case TaskStatusFilter.todo:
        return task.status == TaskStatus.todo;
      case TaskStatusFilter.inProgress:
        return task.status == TaskStatus.inProgress;
      case TaskStatusFilter.completed:
        return task.status == TaskStatus.completed;
      case TaskStatusFilter.dueToday:
        return DueDateLogic.isDueToday(task.dueDate);
      case TaskStatusFilter.overdue:
        return DueDateLogic.isOverdue(task.dueDate);
    }
  }).toList();
});

final filteredAssignedByMeTasksProvider = Provider<List<TaskItem>>((ref) {
  final all = ref.watch(assignedByMeTasksProvider);
  final filter = ref.watch(taskFilterStatusProvider);
  final query = ref.watch(taskSearchQueryProvider).trim().toLowerCase();

  return all.where((task) {
    if (query.isNotEmpty) {
      final matchTitle = task.title.toLowerCase().contains(query);
      final matchDesc = (task.description ?? '').toLowerCase().contains(query);
      final matchAssignee = task.assignedTo.any((a) => a.name.toLowerCase().contains(query));
      final matchAssigner = (task.assignedBy?.name ?? '').toLowerCase().contains(query);
      if (!matchTitle && !matchDesc && !matchAssignee && !matchAssigner) return false;
    }

    switch (filter) {
      case TaskStatusFilter.all:
        return true;
      case TaskStatusFilter.todo:
        return task.status == TaskStatus.todo;
      case TaskStatusFilter.inProgress:
        return task.status == TaskStatus.inProgress;
      case TaskStatusFilter.completed:
        return task.status == TaskStatus.completed;
      case TaskStatusFilter.dueToday:
        return DueDateLogic.isDueToday(task.dueDate);
      case TaskStatusFilter.overdue:
        return DueDateLogic.isOverdue(task.dueDate);
    }
  }).toList();
});
