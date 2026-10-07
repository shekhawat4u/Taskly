enum DueBucket { overdue, dueToday, tomorrow, upcoming, none }

class DueDateLogic {
  const DueDateLogic._();

  static DateTime dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DueBucket bucket(DateTime? due, {DateTime? now}) {
    if (due == null) return DueBucket.none;
    final today = dateOnly(now ?? DateTime.now());
    final target = dateOnly(due);
    if (target.isBefore(today)) return DueBucket.overdue;
    if (target == today) return DueBucket.dueToday;
    if (target == today.add(const Duration(days: 1))) return DueBucket.tomorrow;
    return DueBucket.upcoming;
  }

  static bool isDueToday(DateTime? due, {DateTime? now}) =>
      bucket(due, now: now) == DueBucket.dueToday;

  static bool isOverdue(DateTime? due, {DateTime? now}) =>
      bucket(due, now: now) == DueBucket.overdue;

  static DateTime startOfWeek(DateTime now) {
    final local = now.toLocal();
    final date = dateOnly(local);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }
}
