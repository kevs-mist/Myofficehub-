import 'package:flutter/material.dart';

import '../../../../core/theme/color_scheme.dart';

class PlayfulInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final TextEditingController controller;

  const PlayfulInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'Required';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: color, size: 22),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor,
            contentPadding: const EdgeInsets.all(22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }
}

