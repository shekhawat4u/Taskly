enum DueBucket { overdue, dueToday, tomorrow, upcoming, none }

class DueDateLogic {
  static DueBucket bucket(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    if (d.isBefore(today)) return DueBucket.overdue;
    if (d == today) return DueBucket.dueToday;
    if (d == today.add(const Duration(days: 1))) return DueBucket.tomorrow;
    if (d.isBefore(today.add(const Duration(days: 8)))) return DueBucket.upcoming;
    return DueBucket.none;
  }
}
