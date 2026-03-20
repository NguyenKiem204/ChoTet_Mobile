import 'package:flutter/material.dart';
import '../../../themes/design_system.dart';

class TetProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? activeColor;
  final Color? backgroundColor;
  final bool isOverBudget;

  const TetProgressBar({
    super.key,
    required this.progress,
    this.activeColor,
    this.backgroundColor,
    this.isOverBudget = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOverBudget ? AppColors.danger : (activeColor ?? AppColors.tetRed);

    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? (theme.brightness == Brightness.light ? Colors.grey[200] : Colors.grey[800]),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }
}
