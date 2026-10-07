import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.priorityLow,
    required this.priorityMedium,
    required this.priorityHigh,
    required this.priorityUrgent,
    required this.todoBg,
    required this.todoFg,
    required this.inProgressBg,
    required this.inProgressFg,
    required this.completedBg,
    required this.completedFg,
    required this.navBar,
    required this.unreadDot,
  });

  final Color accent;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color priorityLow;
  final Color priorityMedium;
  final Color priorityHigh;
  final Color priorityUrgent;
  final Color todoBg;
  final Color todoFg;
  final Color inProgressBg;
  final Color inProgressFg;
  final Color completedBg;
  final Color completedFg;
  final Color navBar;
  final Color unreadDot;

  static const light = AppColors(
    accent: Color(0xFF4F46E5),
    background: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE8EAEE),
    textPrimary: Color(0xFF14161A),
    textMuted: Color(0xFF6B7280),
    success: Color(0xFF17876B),
    error: Color(0xFFC0392F),
    priorityLow: Color(0xFF9CA3AF),
    priorityMedium: Color(0xFFD97706),
    priorityHigh: Color(0xFFEA580C),
    priorityUrgent: Color(0xFFDC2626),
    todoBg: Color(0xFFF3F4F6),
    todoFg: Color(0xFF4B5563),
    inProgressBg: Color(0xFFEEF2FF),
    inProgressFg: Color(0xFF4F46E5),
    completedBg: Color(0xFFE6F6F1),
    completedFg: Color(0xFF17876B),
    navBar: Color(0xFFFFFFFF),
    unreadDot: Color(0xFF4F46E5),
  );

  static const dark = AppColors(
    accent: Color(0xFF4F46E5),
    background: Color(0xFF14161A),
    surface: Color(0xFF1C1F26),
    border: Color(0xFF2A2E36),
    textPrimary: Color(0xFFF8FAFC),
    textMuted: Color(0xFF9CA3AF),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    priorityLow: Color(0xFF9CA3AF),
    priorityMedium: Color(0xFFFBBF24),
    priorityHigh: Color(0xFFFB923C),
    priorityUrgent: Color(0xFFF87171),
    todoBg: Color(0xFF2A2E36),
    todoFg: Color(0xFFD1D5DB),
    inProgressBg: Color(0xFF2A2A4A),
    inProgressFg: Color(0xFFA5B4FC),
    completedBg: Color(0xFF16352D),
    completedFg: Color(0xFF34D399),
    navBar: Color(0xFF1C1F26),
    unreadDot: Color(0xFF818CF8),
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? success,
    Color? error,
    Color? priorityLow,
    Color? priorityMedium,
    Color? priorityHigh,
    Color? priorityUrgent,
    Color? todoBg,
    Color? todoFg,
    Color? inProgressBg,
    Color? inProgressFg,
    Color? completedBg,
    Color? completedFg,
    Color? navBar,
    Color? unreadDot,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      error: error ?? this.error,
      priorityLow: priorityLow ?? this.priorityLow,
      priorityMedium: priorityMedium ?? this.priorityMedium,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      priorityUrgent: priorityUrgent ?? this.priorityUrgent,
      todoBg: todoBg ?? this.todoBg,
      todoFg: todoFg ?? this.todoFg,
      inProgressBg: inProgressBg ?? this.inProgressBg,
      inProgressFg: inProgressFg ?? this.inProgressFg,
      completedBg: completedBg ?? this.completedBg,
      completedFg: completedFg ?? this.completedFg,
      navBar: navBar ?? this.navBar,
      unreadDot: unreadDot ?? this.unreadDot,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      priorityLow: Color.lerp(priorityLow, other.priorityLow, t)!,
      priorityMedium: Color.lerp(priorityMedium, other.priorityMedium, t)!,
      priorityHigh: Color.lerp(priorityHigh, other.priorityHigh, t)!,
      priorityUrgent: Color.lerp(priorityUrgent, other.priorityUrgent, t)!,
      todoBg: Color.lerp(todoBg, other.todoBg, t)!,
      todoFg: Color.lerp(todoFg, other.todoFg, t)!,
      inProgressBg: Color.lerp(inProgressBg, other.inProgressBg, t)!,
      inProgressFg: Color.lerp(inProgressFg, other.inProgressFg, t)!,
      completedBg: Color.lerp(completedBg, other.completedBg, t)!,
      completedFg: Color.lerp(completedFg, other.completedFg, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      unreadDot: Color.lerp(unreadDot, other.unreadDot, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
