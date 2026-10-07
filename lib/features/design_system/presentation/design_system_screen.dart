import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../shared/models/task_priority.dart';
import '../../../shared/models/task_status.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/status_chip.dart';

class DesignSystemScreen extends ConsumerWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final themeMode = ref.watch(themeModeProvider);

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
          'Design System',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colors.textPrimary,
            ),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colors Section
            _sectionHeader(context, 'Color Tokens'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _colorSwatch(context, 'Accent', colors.accent, '#4F46E5'),
                _colorSwatch(context, 'Background', colors.background,
                    colors.background.toHex()),
                _colorSwatch(context, 'Surface', colors.surface, '#FFFFFF'),
                _colorSwatch(context, 'Border', colors.border, '#E8EAEE'),
                _colorSwatch(
                    context, 'Text Primary', colors.textPrimary, '#14161A'),
                _colorSwatch(
                    context, 'Text Muted', colors.textMuted, '#6B7280'),
                _colorSwatch(context, 'Success', colors.success, '#17876B'),
                _colorSwatch(context, 'Error/Urgent', colors.error, '#C0392F'),
              ],
            ),

            const SizedBox(height: 28),

            // Typography Scale
            _sectionHeader(context, 'Type Scale — Inter'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _typeRow('H1', 'Screen title', '28 / 700',
                      Theme.of(context).textTheme.displaySmall),
                  _divider(colors),
                  _typeRow('H2', 'Section header', '20 / 600',
                      Theme.of(context).textTheme.headlineSmall),
                  _divider(colors),
                  _typeRow('H3', 'Card title', '16 / 600',
                      Theme.of(context).textTheme.titleMedium),
                  _divider(colors),
                  _typeRow('Body', 'Body text', '15 / 400',
                      Theme.of(context).textTheme.bodyMedium),
                  _divider(colors),
                  _typeRow('Meta', 'Meta / caption', '13 / 400',
                      Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Priority System
            _sectionHeader(context, 'Priority System'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: TaskPriority.values
                    .map((p) => PriorityBadge(priority: p, showLabel: true))
                    .toList(),
              ),
            ),

            const SizedBox(height: 28),

            // Status Chips
            _sectionHeader(context, 'Task Status Chips'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...TaskStatus.values.map((s) => StatusChip(status: s)),
                  StatusChip(
                    status: TaskStatus.todo,
                    customLabel: 'Due Today',
                  ),
                  StatusChip(
                    status: TaskStatus.todo,
                    customLabel: 'Overdue',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Spacing & Corner Radius
            _sectionHeader(context, 'Spacing (8pt) & Radius'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('4px · 8px · 12px · 16px · 24px · 32px · 48px',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [4, 8, 12, 16, 24, 32, 48].map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          width: 14,
                          height: s.toDouble(),
                          color: colors.accent,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Corner Radius: Chip 8px • Card 14px • Sheet 16px • Button 16px',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Buttons
            _sectionHeader(context, 'Buttons & Actions'),
            const SizedBox(height: 12),
            CustomButton(text: 'Primary Button', onPressed: () {}),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Secondary Ghost Button',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Outline Button',
              variant: ButtonVariant.outline,
              onPressed: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _colorSwatch(
      BuildContext context, String name, Color color, String hex) {
    final colors = context.colors;
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          Text(
            hex,
            style: TextStyle(fontSize: 9, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _typeRow(
      String code, String label, String meta, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  code,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              Text(label, style: style?.copyWith(fontSize: 14)),
            ],
          ),
          Text(
            meta,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColors colors) =>
      Divider(color: colors.border, height: 1);
}

extension _ColorHex on Color {
  String toHex() => '#${value.toRadixString(16).substring(2).toUpperCase()}';
}
