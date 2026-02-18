import 'dart:io';
import 'package:officehub_backend/config/env.dart';
import 'package:officehub_backend/services/supabase_crud_service_production.dart';

void main() async {
  print('🔍 Starting Database Verification...');

  try {
    // 1. Initialize environment
    await Env.load();
    print('✅ Environment loaded');

    // 2. Initialize Supabase
    final service = ProductionSupabaseCrudService.instance;
    await service.initialize();
    print('✅ Supabase service initialized');

    // 3. Verify Tables
    final tables = [
      'tenants',
      'events',
      'complaints',
      'payments',
      'admin_settings',
      'cars',
      'staff'
    ];

    print('\n📊 Checking Tables:');
    for (final table in tables) {
      try {
        switch (table) {
          case 'tenants':
            await service.getTenants();
            break;
          case 'events':
            await service.getEvents();
            break;
          case 'complaints':
            await service.getComplaints();
            break;
          case 'payments':
            await service.getPayments();
            break;
          case 'admin_settings':
            // Just check if we can reach the table without side effects/FK violations
            await service.client
                .from('admin_settings')
                .select('admin_id')
                .limit(1);
            break;
          case 'cars':
            await service.getCars();
            break;
          case 'staff':
            await service.getStaff();
            break;
        }

        print('  [✓] $table');
      } catch (e) {
        print('  [✗] $table - ERROR: ${e.toString().split('\n').first}');
      }
    }

    print('\n🚀 Verification complete.');
    exit(0);
  } catch (e) {
    print('\n❌ CRITICAL ERROR: $e');
    exit(1);
  }
}
