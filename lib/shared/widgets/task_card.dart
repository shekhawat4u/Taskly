import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/date_time_x.dart';
import '../models/task_item.dart';
import 'priority_badge.dart';
import 'status_chip.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showAssignerInsteadOfAssignee = false,
  });

  final TaskItem task;
  final VoidCallback? onTap;
  final bool showAssignerInsteadOfAssignee;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final displayedUsers = showAssignerInsteadOfAssignee
        ? (task.assignedBy != null ? [task.assignedBy!] : task.assignedTo)
        : (task.assignedTo.isNotEmpty ? task.assignedTo : (task.assignedBy != null ? [task.assignedBy!] : []));
    
    final displayedUser = displayedUsers.isNotEmpty ? displayedUsers.first : null;
    final userName = displayedUser?.name.split(' ').first ?? 'User';

    String dueText = '';
    if (task.dueDate != null) {
      dueText = ' • ${task.dueDate!.shortDate}';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar(s)
                if (displayedUsers.length <= 1)
                  UserAvatar(
                    name: displayedUser?.name ?? 'User',
                    avatarUrl: displayedUser?.avatarUrl,
                    size: 34,
                  )
                else
                  SizedBox(
                    width: 34.0 + ((displayedUsers.length > 3 ? 3 : displayedUsers.length) - 1) * 12,
                    height: 34,
                    child: Stack(
                      children: List.generate(
                        displayedUsers.length > 3 ? 3 : displayedUsers.length,
                        (index) {
                          if (index == 2 && displayedUsers.length > 3) {
                            return Positioned(
                              left: index * 12.0,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: colors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colors.surface, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${displayedUsers.length - 2}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Positioned(
                            left: index * 12.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.surface, width: 2),
                              ),
                              child: UserAvatar(
                                name: displayedUsers[index].name,
                                avatarUrl: displayedUsers[index].avatarUrl,
                                size: 30, // Slightly smaller to account for border
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                const SizedBox(width: 12),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$userName$dueText',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PriorityBadge(priority: task.priority),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Chip on Right
                StatusChip(status: task.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
