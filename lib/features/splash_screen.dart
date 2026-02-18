import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/color_scheme.dart';
import '../core/routing/route_names.dart';
import '../core/widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteNames.roleSelection);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppBackground(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Synthesized Logo (Structural + Vibrant)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .shimmer(duration: 2.seconds, delay: 1.seconds),

                const SizedBox(height: 32),

                const Text(
                  'MyOfficeHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MODERN MANAGEMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
              ],
            ),
          ),
      ),
    );
  }
}
