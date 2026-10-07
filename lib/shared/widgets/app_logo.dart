import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showWordmark = true,
    this.showTagline = true,
    this.tagline = 'Get things done, together',
  });

  final double size;
  final bool showWordmark;
  final bool showTagline;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final logoIcon = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/taskly_logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (!showWordmark) {
      return logoIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        const SizedBox(height: 16),
        Text(
          'Taskly',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colors.textPrimary,
              ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ],
    );
  }
}
