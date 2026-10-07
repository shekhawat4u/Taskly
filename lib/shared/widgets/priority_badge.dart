import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../models/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
    this.dotSize = 6,
  });

  final TaskPriority priority;
  final bool showLabel;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color color;
    switch (priority) {
      case TaskPriority.low:
        color = colors.priorityLow;
        break;
      case TaskPriority.medium:
        color = colors.priorityMedium;
        break;
      case TaskPriority.high:
        color = colors.priorityHigh;
        break;
      case TaskPriority.urgent:
        color = colors.priorityUrgent;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 5),
          Text(
            priority.label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }
}
