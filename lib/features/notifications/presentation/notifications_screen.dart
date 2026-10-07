import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/models/notification_type.dart';
import '../../../shared/widgets/empty_state.dart';
import 'notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final notifications = ref.watch(notificationsFeedProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: colors.textPrimary),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationActionsProvider).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read.'),
                  backgroundColor: colors.accent,
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              title: 'No notifications',
              message: 'You are all caught up!',
              icon: Icons.notifications_none_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationRow(
                  notification: notif,
                  onTap: () {
                    if (notif.taskId != null) {
                      context.push('/task-details/${notif.taskId}');
                    }
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: colors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (bottomSheetContext) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: colors.border,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete_outline_rounded, color: colors.error),
                                  title: Text(
                                    'Delete Notification',
                                    style: TextStyle(
                                      color: colors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(bottomSheetContext);
                                    ref.read(notificationActionsProvider).deleteNotification(notif.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Notification deleted'),
                                        backgroundColor: colors.textPrimary,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    IconData iconData;
    Color iconBg;
    Color iconFg;

    switch (notification.type) {
      case NotificationType.taskAssigned:
        iconData = Icons.assignment_turned_in_outlined;
        iconBg = colors.inProgressBg;
        iconFg = colors.accent;
        break;
      case NotificationType.taskStarted:
        iconData = Icons.play_arrow_rounded;
        iconBg = const Color(0xFFE0F2FE);
        iconFg = const Color(0xFF0284C7);
        break;
      case NotificationType.taskCompleted:
        iconData = Icons.check_circle_outline_rounded;
        iconBg = colors.completedBg;
        iconFg = colors.success;
        break;
      case NotificationType.taskDue:
        iconData = Icons.schedule_rounded;
        iconBg = const Color(0xFFFEF3C7);
        iconFg = colors.priorityMedium;
        break;
      case NotificationType.taskOverdue:
        iconData = Icons.error_outline_rounded;
        iconBg = const Color(0xFFFEE2E2);
        iconFg = colors.priorityUrgent;
        break;
      case NotificationType.taskCommented:
        iconData = Icons.comment_outlined;
        iconBg = const Color(0xFFF1F5F9);
        iconFg = colors.textPrimary;
        break;
      case NotificationType.taskUpdated:
        iconData = Icons.update_rounded;
        iconBg = const Color(0xFFE0E7FF);
        iconFg = const Color(0xFF4F46E5);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: !notification.isRead ? colors.accent.withValues(alpha: 0.05) : colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: !notification.isRead ? colors.accent.withValues(alpha: 0.3) : colors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconFg,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Notification message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: !notification.isRead ? colors.textPrimary : colors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: !notification.isRead ? colors.textPrimary.withValues(alpha: 0.9) : colors.textMuted,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.createdAt.relative,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread dot
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 6, left: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
