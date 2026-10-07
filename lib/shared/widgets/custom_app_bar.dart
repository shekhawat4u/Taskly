import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.bottom,
    this.centerTitle = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: colors.textPrimary,
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    }

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leadingWidget,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
