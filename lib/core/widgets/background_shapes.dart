import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/color_scheme.dart';

class BackgroundShapes extends StatelessWidget {
  const BackgroundShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subdued Radial Glow (Serious)
        Positioned(
          top: -100,
          right: -100,
          child:
              _GlowShape(
                    size: 400,
                    color: AppColors.accent.withValues(alpha: 0.08),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 8.seconds,
                  ),
        ),
        // Defined Floating Bubble (Fun/Colorful)
        Positioned(
          bottom: 100,
          left: -80,
          child:
              Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: AppColors.blob1,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .moveY(
                    begin: 0,
                    end: -50,
                    duration: 5.seconds,
                    curve: Curves.easeInOutSine,
                  ),
        ),
      ],
    );
  }
}

class _GlowShape extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        shape: BoxShape.circle,
      ),
    );
  }
}
