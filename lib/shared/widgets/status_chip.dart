import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../models/task_status.dart';

enum TaskStatusFilter {
  all,
  todo,
  inProgress,
  completed,
  dueToday,
  overdue;

  String get label {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.todo:
        return 'To Do';
      case TaskStatusFilter.inProgress:
        return 'In Progress';
      case TaskStatusFilter.completed:
        return 'Completed';
      case TaskStatusFilter.dueToday:
        return 'Due Today';
      case TaskStatusFilter.overdue:
        return 'Overdue';
    }
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
    this.customLabel,
  });

  final TaskStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;

    switch (status) {
      case TaskStatus.todo:
        bg = colors.todoBg;
        fg = colors.todoFg;
        break;
      case TaskStatus.inProgress:
        bg = colors.inProgressBg;
        fg = colors.inProgressFg;
        break;
      case TaskStatus.completed:
        bg = colors.completedBg;
        fg = colors.completedFg;
        break;
    }

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Text(
        customLabel ?? status.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class FilterStatusChip extends StatelessWidget {
  const FilterStatusChip({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  final TaskStatusFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: 1,
          ),
        ),
        child: Text(
          filter.label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
