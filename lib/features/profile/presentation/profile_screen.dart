import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../team/presentation/team_provider.dart';
import '../../tasks/presentation/task_provider.dart';
import '../../../shared/models/task_status.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final user = ref.watch(authStateProvider).valueOrNull;
    final team = ref.watch(teamMembersProvider);
    final themeMode = ref.watch(themeModeProvider);
    final allTasks = ref.watch(allTasksProvider);
    
    // Calculate stats
    final myTasks = allTasks.where((t) => t.assignedToIds.contains(user?.id)).toList();
    final completedCount = myTasks.where((t) => t.status == TaskStatus.completed).length;
    final activeCount = myTasks.length - completedCount;

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Minimal Centered Avatar & Info
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 2),
                    ),
                    child: UserAvatar(
                      name: user?.name ?? 'User',
                      avatarUrl: user?.avatarUrl,
                      size: 90,
                      showBorder: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User Name',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? 'user@company.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.label.toUpperCase() ?? 'ROLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Very light gradient stats box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.04),
                    colors.accent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.accent.withValues(alpha: 0.1), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(label: 'Active Tasks', count: '$activeCount', colors: colors),
                  Container(width: 1, height: 40, color: colors.border),
                  _StatColumn(label: 'Completed', count: '$completedCount', colors: colors),
                  if (user?.role.canManageUsers == true) ...[
                    Container(width: 1, height: 40, color: colors.border),
                    _StatColumn(label: 'Team Size', count: '${team.length}', colors: colors),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Menu Sections
            _SectionHeader(title: 'WORKSPACE', colors: colors),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  if (user?.role.canManageUsers == true) ...[
                    _ProfileMenuItem(
                      icon: Icons.groups_outlined,
                      title: 'Manage Team',
                      onTap: () => context.push('/team'),
                    ),
                    _divider(colors),
                    _ProfileMenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'Analytics & Reports',
                      onTap: () => context.push('/analytics'),
                    ),
                    _divider(colors),
                  ],
                  _ProfileMenuItem(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Completed Tasks',
                    onTap: () => context.push('/completed-tasks'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _SectionHeader(title: 'APP SETTINGS', colors: colors),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: 'Theme',
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDark ? 'Dark' : 'Light',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: colors.textMuted),
                      ],
                    ),
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                          isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.error,
                  elevation: 0,
                  side: BorderSide(color: colors.border, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                ),
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(color: colors.border, height: 1),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.colors});
  final String title;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.count, required this.colors});
  final String label;
  final String count;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingBadge,
    this.trailingWidget,
    this.titleColor,
    this.iconColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingBadge;
  final Widget? trailingWidget;
  final Color? titleColor;
  final Color? iconColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? colors.textPrimary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailingBadge != null) ...[
              Text(
                trailingBadge!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (trailingWidget != null) ...[
              trailingWidget!,
            ] else if (showChevron) ...[
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
