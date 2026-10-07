import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'custom_button.dart';

class CompletionBottomSheet extends StatelessWidget {
  const CompletionBottomSheet({
    super.key,
    required this.onConfirm,
    this.taskTitle,
  });

  final VoidCallback onConfirm;
  final String? taskTitle;

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    String? taskTitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CompletionBottomSheet(
        onConfirm: () {
          Navigator.of(context).pop(true);
          onConfirm();
        },
        taskTitle: taskTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Celebration Icon 🎉
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🎉',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Headline
          Text(
            'Mark this task as completed?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Supporting Text
          Text(
            'You will be able to see it in History.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Mark Completed',
                  variant: ButtonVariant.primary,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
