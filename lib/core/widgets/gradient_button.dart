import 'package:flutter/material.dart';

/// A full-width button with a gradient background.
///
/// This keeps the "gradient container + transparent ElevatedButton" pattern
/// consistent across screens.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final LinearGradient gradient;
  final double height;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;
  final Widget? trailing;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.gradient,
    this.height = 64,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.boxShadow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

