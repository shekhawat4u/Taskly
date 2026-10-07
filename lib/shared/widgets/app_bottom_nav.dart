import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadNotificationsCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadNotificationsCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final items = [
      _NavItem(
        index: 0,
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _NavItem(
        index: 1,
        label: 'Tasks',
        icon: Icons.task_alt_outlined,
        activeIcon: Icons.task_alt_rounded,
      ),
      _NavItem(
        index: 2,
        label: 'Calendar',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
      ),
      _NavItem(
        index: 3,
        label: 'Notifications',
        icon: Icons.notifications_none_rounded,
        activeIcon: Icons.notifications_rounded,
        badgeCount: unreadNotificationsCount,
      ),
      _NavItem(
        index: 4,
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.navBar,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isSelected = currentIndex == item.index;
          final color = isSelected ? colors.accent : colors.textMuted;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(item.index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: color,
                        size: 24,
                      ),
                      if (item.badgeCount > 0)
                        Positioned(
                          right: -4,
                          top: -2,
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
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;
}

class FloatingCreateFab extends StatelessWidget {
  const FloatingCreateFab({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
