// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_scheme.dart';
import '../../../../core/ui/app_layout.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/backend_config.dart';
import 'widgets/animated_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      if (_isSignUp) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        // Send email verification immediately
        await credential.user?.sendEmailVerification();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
          ),
        );
        setState(() => _isSignUp = false); // Switch to sign in mode
      } else {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = credential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email not verified. A new verification link has been sent.',
              ),
            ),
          );
          return;
        }

        if (!mounted) return;
        _navigateBasedOnRole();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _navigateBasedOnRole() {
    context.goNamed(RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppLayout.screenInsetsWide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppLayout.v40,
                IconButton(
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => context.goNamed(RouteNames.roleSelection),
                ),
                AppLayout.v40,
                GestureDetector(
                  onLongPress: () async {
                    final newValue = !BackendConfig.isRealApi;
                    await BackendConfig.setUseRealApi(newValue);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Environment Switched to: ${newValue ? "PRODUCTION (Supabase)" : "DEVELOPMENT (Mock API)"}',
                        ),
                        backgroundColor: newValue ? Colors.orange : Colors.blue,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    // Force rebuild of dependencies dependent on API Service
                    context.goNamed(RouteNames.roleSelection);
                  },
                  child: Text(
                    _isSignUp ? 'Create Account' : 'Welcome\nBack',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -2,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),
                ),
                AppLayout.v12,
                Text(
                  _isSignUp
                      ? 'Create your workspace account.'
                      : 'Sign in to access your workspace.',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                AppLayout.v60,

                // INPUT FIELDS
                AnimatedInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  delay: 400.ms,
                  keyboardType: TextInputType.emailAddress,
                ),

                AppLayout.v24,

                AnimatedInputField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  delay: 500.ms,
                  obscureText: true,
                ),

                AppLayout.v24,

                // TOGGLE SIGN IN / SIGN UP & FORGOT PASSWORD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign In'
                            : 'Don\'t have an account? Sign Up',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!_isSignUp)
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                AppLayout.v60,

                // LOGIN BUTTON
                GradientButton(
                  onPressed: _busy ? null : _submit,
                  label: _isSignUp ? 'SIGN UP' : 'SIGN IN',
                  gradient: AppColors.primaryGradient,
                  height: 64,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).scale(),

                AppLayout.v24,

                // DEMO & SIGN UP
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: _navigateBasedOnRole,
                        child: const Text(
                          'USE DEMO ACCESS',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),

                AppLayout.v40,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
