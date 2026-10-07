import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/models/task_item.dart';
import '../../../shared/widgets/task_card.dart';
import '../../tasks/presentation/task_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allTasks = ref.watch(allTasksProvider);

    // Group tasks by due date
    final tasksByDate = <DateTime, List<TaskItem>>{};
    for (final task in allTasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        tasksByDate.putIfAbsent(date, () => []).add(task);
      }
    }

    final selectedDateOnly = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final tasksForSelectedDay = tasksByDate[selectedDateOnly] ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                final d = DateTime(day.year, day.month, day.day);
                return tasksByDate[d] ?? [];
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: colors.priorityUrgent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasksForSelectedDay.isEmpty
                ? Center(
                    child: Text(
                      'No tasks due on this date.',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDay[index];
                      return TaskCard(
                        task: task,
                        onTap: () => context.push('/task-details/${task.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
