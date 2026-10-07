import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 36,
    this.radius,
    this.showBorder = false,
  });

  final String name;
  final String? avatarUrl;
  final double size;
  final double? radius;
  final bool showBorder;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Color _getGradientColor(String text) {
    final hash = text.codeUnits.fold(0, (prev, elem) => prev + elem);
    final colors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFF10B981), // Emerald
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    final fallbackColor = _getGradientColor(name);

    Widget avatarContent;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarContent = CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _fallbackWidget(fallbackColor),
        errorWidget: (context, url, error) => _fallbackWidget(fallbackColor),
      );
    } else {
      avatarContent = _fallbackWidget(fallbackColor);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: appColors.border, width: 1.5) : null,
      ),
      child: ClipOval(child: avatarContent),
    );
  }

  Widget _fallbackWidget(Color bg) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg,
            bg.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.40,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
