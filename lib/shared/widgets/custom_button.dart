import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, outline, destructive }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bg = colors.accent;
        fg = Colors.white;
        break;
      case ButtonVariant.secondary:
        bg = colors.todoBg;
        fg = colors.textPrimary;
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = colors.textPrimary;
        borderSide = BorderSide(color: colors.border, width: 1);
        break;
      case ButtonVariant.destructive:
        bg = colors.error.withValues(alpha: 0.1);
        fg = colors.error;
        break;
    }

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
        boxShadow: variant == ButtonVariant.primary && onPressed != null
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Logo G
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.g_mobiledata_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
