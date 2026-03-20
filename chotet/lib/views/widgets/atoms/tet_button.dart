import 'package:flutter/material.dart';
import '../../../themes/design_system.dart';

enum TetButtonVariant {
  primary,
  secondary,
  outline,
  dashed,
}

class TetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TetButtonVariant variant;
  final IconData? icon;
  final bool isFullWidth;

  const TetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TetButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.s),
        ],
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: _getTextColor(theme),
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButtonBody(context, content),
    );
  }

  Widget _buildButtonBody(BuildContext context, Widget child) {
    switch (variant) {
      case TetButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tetRed,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
          ),
          child: child,
        );
      case TetButtonVariant.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tetGold,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
          ),
          child: child,
        );
      case TetButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.tetRed,
            side: const BorderSide(color: AppColors.tetRed),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
          ),
          child: child,
        );
      case TetButtonVariant.dashed:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tetRed,
              side: BorderSide(
                color: AppColors.tetRed.withValues(alpha: 0.3),
                style: BorderStyle.solid, // Flutter doesn't natively support dashed borders easily in standard OutlinedButton
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.l),
              ),
            ),
            child: child,
          ),
        );
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (variant == TetButtonVariant.primary || variant == TetButtonVariant.secondary) {
      return AppColors.white;
    }
    return AppColors.tetRed;
  }
}
