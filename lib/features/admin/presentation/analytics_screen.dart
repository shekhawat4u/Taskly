import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_colors.dart';
import '../../tasks/presentation/task_provider.dart';
import '../../../shared/models/task_item.dart';
import '../../../shared/models/task_status.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final allTasks = ref.watch(allTasksProvider);

    int completed = 0;
    int inProgress = 0;
    int overdue = 0;
    int todo = 0;

    final now = DateTime.now();

    for (final task in allTasks) {
      if (task.status == TaskStatus.completed) {
        completed++;
      } else {
        if (task.dueDate != null && task.dueDate!.isBefore(now)) {
          overdue++;
        } else if (task.status == TaskStatus.inProgress) {
          inProgress++;
        } else {
          todo++;
        }
      }
    }

    final total = allTasks.length;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (total == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No data available',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      if (completed > 0)
                        PieChartSectionData(
                          value: completed.toDouble(),
                          title: '$completed',
                          color: colors.success,
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      if (inProgress > 0)
                        PieChartSectionData(
                          value: inProgress.toDouble(),
                          title: '$inProgress',
                          color: colors.accent,
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      if (overdue > 0)
                        PieChartSectionData(
                          value: overdue.toDouble(),
                          title: '$overdue',
                          color: colors.priorityUrgent,
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      if (todo > 0)
                        PieChartSectionData(
                          value: todo.toDouble(),
                          title: '$todo',
                          color: colors.priorityLow,
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: colors.success, label: 'Completed'),
                _LegendItem(color: colors.accent, label: 'In Progress'),
                _LegendItem(color: colors.priorityUrgent, label: 'Overdue'),
                _LegendItem(color: colors.priorityLow, label: 'To Do'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: context.colors.textMuted),
        ),
      ],
    );
  }
}
