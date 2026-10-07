import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import 'admin_provider.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  void _showRetentionDialog(BuildContext context, WidgetRef ref, int current) {
    final colors = context.colors;
    int selected = current;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
          ),
          title: Text(
            'Retention Policy',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Automatically delete completed tasks older than:',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
              const SizedBox(height: 16),
              ...[30, 90, 180, 365].map((days) => RadioListTile<int>(
                    value: days,
                    groupValue: selected,
                    activeColor: colors.accent,
                    title: Text(
                      '$days days',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) setState(() => selected = val);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(adminActionsProvider)
                    .updateRetentionDays(selected);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Retention policy set to $selected days.'),
                    backgroundColor: colors.accent,
                  ),
                );
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final org = ref.watch(organizationProvider);
    final settings = ref.watch(organizationSettingsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Admin Panel',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Org Card Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business_rounded,
                        color: colors.accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Startup Enterprise Plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.completedBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.completedFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Management & Settings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Settings Rows Container
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  _AdminRow(
                    icon: Icons.people_outline_rounded,
                    title: 'Users',
                    subtitle: 'Manage users & roles',
                    onTap: () => context.push('/team'),
                  ),
                  _divider(colors),
                  _AdminRow(
                    icon: Icons.security_outlined,
                    title: 'Roles & Permissions',
                    subtitle: 'Manage roles',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Roles: Founder, Admin, Employee, Intern'),
                          backgroundColor: colors.textPrimary,
                        ),
                      );
                    },
                  ),
                  _divider(colors),
                  _AdminRow(
                    icon: Icons.checklist_outlined,
                    title: 'All Tasks',
                    subtitle: 'View all tasks across organisation',
                    onTap: () => context.push('/tasks'),
                  ),
                  _divider(colors),
                  _AdminRow(
                    icon: Icons.auto_delete_outlined,
                    title: 'Retention Policy',
                    subtitle:
                        'Auto delete after ${settings.completedTaskRetentionDays} days',
                    onTap: () => _showRetentionDialog(
                        context, ref, settings.completedTaskRetentionDays),
                  ),
                  _divider(colors),
                  _AdminRow(
                    icon: Icons.settings_suggest_outlined,
                    title: 'Organisation Settings',
                    subtitle: 'Company details & billing',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Taskly Labs • Billing up to date'),
                          backgroundColor: colors.textPrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors colors) =>
      Divider(color: colors.border, height: 1, indent: 56, endIndent: 16);
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.todoBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: colors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
