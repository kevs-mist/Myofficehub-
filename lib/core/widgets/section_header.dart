import 'package:flutter/material.dart';
import '../theme/color_scheme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String? actionText;

  const SectionHeader({
    super.key,
    required this.title,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (onAction != null && actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(actionText!),
          ),
      ],
    );
  }
}
