import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/color_scheme.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

import 'core/services/notification_service.dart';

class MyOfficeHubApp extends ConsumerStatefulWidget {
  const MyOfficeHubApp({super.key});

  @override
  ConsumerState<MyOfficeHubApp> createState() => _MyOfficeHubAppState();
}

class _MyOfficeHubAppState extends ConsumerState<MyOfficeHubApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications
    Future.microtask(() {
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'MyOfficeHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      color: AppColors.primary,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }
}
