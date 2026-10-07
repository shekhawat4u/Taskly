import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../notifications/presentation/notification_provider.dart';
import '../../tasks/presentation/task_provider.dart';
import '../../../shared/models/task_status.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../tasks/presentation/tasks_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final user = ref.watch(authStateProvider).valueOrNull;
    final stats = ref.watch(homeStatsProvider);
    final myTasks = ref
        .watch(assignedToMeTasksProvider)
        .where((t) => t.status != TaskStatus.completed)
        .toList();
    final assignedByMeTasks = ref
        .watch(assignedByMeTasksProvider)
        .where((t) => t.status != TaskStatus.completed)
        .toList();
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);

    final now = DateTime.now();
    final greeting = '${now.greeting}, ${user?.name.split(' ').first ?? 'User'} 👋';
    final dateSubtitle = DateFormat('EEEE, d MMM').format(now);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                ref.read(taskStateRevisionProvider.notifier).state++;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dateSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // Notification bell with unread dot
                            IconButton(
                              onPressed: () => context.push('/notifications'),
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    color: colors.textPrimary,
                                    size: 24,
                                  ),
                                  if (unreadNotifs > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: colors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            // User Avatar
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: UserAvatar(
                                name: user?.name ?? 'User',
                                avatarUrl: user?.avatarUrl,
                                size: 36,
                                showBorder: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 4-Card Statistics Grid
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                value: '${stats.assignedToMe}',
                                label: 'Assigned to me',
                                onTap: () {
                                  ref.read(tasksTabProvider.notifier).state = 0;
                                  context.push('/tasks');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: '${stats.dueToday}',
                                label: 'Due today',
                                onTap: () {
                                  ref.read(tasksTabProvider.notifier).state = 0;
                                  context.push('/tasks');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                value: '${stats.inProgress}',
                                label: 'In progress',
                                onTap: () {
                                  ref.read(tasksTabProvider.notifier).state = 0;
                                  context.push('/tasks');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: '${stats.completedThisWeek}',
                                label: 'Completed this week',
                                onTap: () => context.push('/completed-tasks'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // "My Tasks" Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(tasksTabProvider.notifier).state = 0;
                            context.push('/tasks');
                          },
                          child: Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (myTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.todoBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.celebration_rounded, size: 36, color: colors.accent),
                            const SizedBox(height: 12),
                            Text(
                              'You\'re all caught up!',
                              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No pending tasks assigned to you.',
                              style: TextStyle(color: colors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      ...myTasks.take(4).map((task) => TaskCard(
                            task: task,
                            onTap: () => context.push('/task-details/${task.id}'),
                          )),

                    const SizedBox(height: 24),

                    // "Assigned by Me" Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Assigned by Me',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(tasksTabProvider.notifier).state = 1;
                            context.push('/tasks');
                          },
                          child: Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (assignedByMeTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_ind_outlined, size: 36, color: colors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'Nothing assigned yet',
                              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You haven\'t assigned any tasks.',
                              style: TextStyle(color: colors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      ...assignedByMeTasks.take(3).map((task) => TaskCard(
                            task: task,
                            showAssignerInsteadOfAssignee: false,
                            onTap: () => context.push('/task-details/${task.id}'),
                          )),

                    const SizedBox(height: 80), // bottom padding for FAB
                  ],
                ),
              ),
            ),

            // Floating + Button in bottom right
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingCreateFab(
                onPressed: () => context.push('/create-task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
