import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_profile_model.dart';
import 'app_state_provider.dart';

final tenantProfileProvider = FutureProvider<TenantProfileModel?>((ref) async {
  final api = ref.watch(mockApiServiceProvider);
  final data = await api.getTenantProfile();
  if (data == null) return null;
  return TenantProfileModel.fromJson(data);
});
