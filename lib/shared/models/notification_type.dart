enum NotificationType {
  taskAssigned,
  taskStarted,
  taskCompleted,
  taskDue,
  taskOverdue,
  taskCommented,
  taskUpdated;

  static NotificationType fromDb(String value) {
    switch (value) {
      case 'task_started':
        return NotificationType.taskStarted;
      case 'task_completed':
        return NotificationType.taskCompleted;
      case 'task_due':
        return NotificationType.taskDue;
      case 'task_overdue':
        return NotificationType.taskOverdue;
      case 'task_commented':
        return NotificationType.taskCommented;
      case 'task_updated':
        return NotificationType.taskUpdated;
      default:
        return NotificationType.taskAssigned;
    }
  }

  String get dbValue {
    switch (this) {
      case NotificationType.taskAssigned:
        return 'task_assigned';
      case NotificationType.taskStarted:
        return 'task_started';
      case NotificationType.taskCompleted:
        return 'task_completed';
      case NotificationType.taskDue:
        return 'task_due';
      case NotificationType.taskOverdue:
        return 'task_overdue';
      case NotificationType.taskCommented:
        return 'task_commented';
      case NotificationType.taskUpdated:
        return 'task_updated';
    }
  }
}
