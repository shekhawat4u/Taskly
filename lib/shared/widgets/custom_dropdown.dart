import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../models/task_priority.dart';
import 'priority_badge.dart';

class PriorityDropdown extends StatelessWidget {
  const PriorityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
  });

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskPriority>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
              dropdownColor: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem<TaskPriority>(
                  value: priority,
                  child: PriorityBadge(
                    priority: priority,
                    showLabel: true,
                    dotSize: 8,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
