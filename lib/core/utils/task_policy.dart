import '../../shared/models/task_item.dart';
import '../../shared/models/task_status.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/user_role.dart';
import 'due_date.dart';

class TaskPolicy {
  const TaskPolicy._();

  static bool canStart(TaskItem task, UserProfile me) {
    if (task.status != TaskStatus.todo) return false;
    return task.assignedToIds.contains(me.id) || me.role.canAccessAdmin;
  }

  static bool canComplete(TaskItem task, UserProfile me) {
    if (task.status == TaskStatus.completed) return false;
    return task.assignedToIds.contains(me.id) || me.role.canAccessAdmin;
  }

  static int compareActive(TaskItem a, TaskItem b, {DateTime? now}) {
    int rank(TaskItem task) {
      final due = DueDateLogic.bucket(task.dueDate, now: now);
      if (due == DueBucket.overdue) return 0;
      if (due == DueBucket.dueToday) return 1;
      return 2 + task.priority.rank;
    }

    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final aDue = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDue = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aDue.compareTo(bDue);
  }

  static TaskStatus? nextStatus(TaskStatus current) {
    switch (current) {
      case TaskStatus.todo:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.completed;
      case TaskStatus.completed:
        return null;
    }
  }
}
