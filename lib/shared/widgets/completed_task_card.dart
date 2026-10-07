import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../models/task_item.dart';
import 'priority_badge.dart';

class CompletedTaskCard extends StatelessWidget {
  const CompletedTaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final TaskItem task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final completedByName =
        task.completedBy?.name.split(' ').first ??
        (task.assignedTo.isNotEmpty ? task.assignedTo.first.name.split(' ').first : 'User');

    String dateStr = '';
    if (task.completedAt != null) {
      dateStr = ' • ${DateFormat('d MMM').format(task.completedAt!)}';
    } else if (task.updatedAt != null) {
      dateStr = ' • ${DateFormat('d MMM').format(task.updatedAt!)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Green outlined checkmark icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.completedBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.success.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Completed by $completedByName$dateStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Priority Badge
                PriorityBadge(
                  priority: task.priority,
                  showLabel: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
