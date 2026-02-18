import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  // Load connection details
  var dotEnv = DotEnv()..load(['.env']);
  final supabaseUrl = dotEnv['SUPABASE_URL'] ?? '';
  final serviceKey = dotEnv['SUPABASE_SERVICE_KEY'] ?? '';

  if (supabaseUrl.isEmpty || serviceKey.isEmpty) {
    print('❌ Error: SUPABASE_URL or SUPABASE_SERVICE_KEY not set.');
    return;
  }

  final supabase = SupabaseClient(supabaseUrl, serviceKey);

  final adminEmail = 'admin@skyline.com';

  print('🔄 Checking for admin user: $adminEmail');

  try {
    // 1. Check if ANY user exists (to debug connection)
    final allTenants = await supabase.from('tenants').select().limit(1);
    print(
        'ℹ️  Connection Check: Found ${allTenants.length} tenants in database.');

    // 2. Upsert Admin User
    // We use upsert to create if missing, or update if exists.
    final tenantResponse = await supabase
        .from('tenants')
        .upsert({
          'email': adminEmail,
          // We need a dummy firebase_uid if one doesn't exist, as it's unique.
          'firebase_uid': 'admin_uid_demo',
          'display_name': 'Admin User',
          'role': 'admin',
          'is_active': true,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'email')
        .select()
        .single();

    print('✅ Admin Tenant Record: ID=${tenantResponse['id']}');

    // 3. Ensure Admin Settings exist
    final adminId = tenantResponse['id'];
    final settingsResponse = await supabase
        .from('admin_settings')
        .select()
        .eq('admin_id', adminId)
        .maybeSingle();

    if (settingsResponse == null) {
      print('⚙️  Creating default admin settings...');
      await supabase.from('admin_settings').insert({
        'admin_id': adminId,
        'office_complex_name': 'Skyline Business Park',
        'maintenance_fee': 5000,
        'parking_fee': 1500,
        'late_fee': 250,
        'upi_id': 'skyline@upi',
        'whatsapp_group_number': '+91 9000000000',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ Admin Settings created.');
    } else {
      print('✅ Admin Settings already exist.');
    }
  } catch (e) {
    print('❌ Error creating/verifying admin: $e');
  }
}
