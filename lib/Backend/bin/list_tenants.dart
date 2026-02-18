import 'package:supabase/supabase.dart';

import 'package:dotenv/dotenv.dart';

void main() async {
  var dotEnv = DotEnv()..load(['.env']);
  final supabase = SupabaseClient(
    dotEnv['SUPABASE_URL'] ?? '',
    dotEnv['SUPABASE_SERVICE_KEY'] ?? '',
  );

  try {
    final response = await supabase.from('tenants').select();
    print('--- Tenants in Supabase ---');
    for (var tenant in response) {
      print(
          'ID: ${tenant['id']}, Email: ${tenant['email']}, Role: ${tenant['role']}');
    }
    if (response.isEmpty) {
      print('No tenants found.');
    }
  } catch (e) {
    print('❌ Error fetching tenants: $e');
  }
}
