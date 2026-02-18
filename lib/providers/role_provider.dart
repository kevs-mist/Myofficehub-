import 'package:flutter_riverpod/flutter_riverpod.dart';

// Role state - True if Admin, False if Tenant
class RoleNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default to Admin for demo

  void setAdmin() => state = true;
  void setTenant() => state = false;
  void toggle() => state = !state;
}

final roleProvider = NotifierProvider<RoleNotifier, bool>(() => RoleNotifier());
