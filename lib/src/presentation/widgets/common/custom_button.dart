import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, text }

enum ButtonIconPosition { left, right }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final ButtonIconPosition iconPosition;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.iconPosition = ButtonIconPosition.left,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Widget child =
        isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(theme, variant, isEnabled),
                ),
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null &&
                    iconPosition == ButtonIconPosition.left) ...[
                  icon!,
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(theme, variant, isEnabled),
                  ),
                ),
                if (icon != null &&
                    iconPosition == ButtonIconPosition.right) ...[
                  const SizedBox(width: 10),
                  icon!,
                ],
              ],
            );

    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(context, theme, child, isEnabled),
    );
  }

  Widget _buildButton(
    BuildContext context,
    ThemeData theme,
    Widget child,
    bool isEnabled,
  ) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withAlpha(20),
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: isEnabled ? 2 : 0,
            shadowColor: theme.colorScheme.primary.withAlpha(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        );

      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.secondary.withAlpha(20),
            foregroundColor: theme.colorScheme.onSecondary,
            elevation: isEnabled ? 1 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        );

      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor:
                isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withAlpha(20),
            side: BorderSide(
              color:
                  isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withAlpha(20),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor:
                isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withAlpha(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: child,
        );
    }
  }

  Color _getTextColor(ThemeData theme, ButtonVariant variant, bool isEnabled) {
    if (!isEnabled) {
      return theme.colorScheme.onSurface.withAlpha(20);
    }

    switch (variant) {
      case ButtonVariant.primary:
        return theme.colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return theme.colorScheme.onSecondary;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
