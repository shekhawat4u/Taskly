import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'due_date.dart';

extension DateTimeX on DateTime {
  String get greeting {
    final hour = toLocal().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get longDate => DateFormat('EEEE, d MMM').format(toLocal());

  String get shortDate {
    final bucket = DueDateLogic.bucket(this);
    switch (bucket) {
      case DueBucket.dueToday:
        return 'Today';
      case DueBucket.tomorrow:
        return 'Tomorrow';
      case DueBucket.overdue:
        return 'Overdue · ${DateFormat('d MMM').format(toLocal())}';
      case DueBucket.upcoming:
      case DueBucket.none:
        return DateFormat('d MMM').format(toLocal());
    }
  }

  String get dueMeta {
    final bucket = DueDateLogic.bucket(this);
    switch (bucket) {
      case DueBucket.dueToday:
        return 'Due today';
      case DueBucket.tomorrow:
        return 'Due tomorrow';
      case DueBucket.overdue:
        return 'Overdue';
      case DueBucket.upcoming:
      case DueBucket.none:
        return 'Due ${DateFormat('d MMM').format(toLocal())}';
    }
  }

  String get relative => timeago.format(toLocal(), allowFromNow: true);

  String get dateTimeLabel => DateFormat("d MMM, h:mm a").format(toLocal());
}
