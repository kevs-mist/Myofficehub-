import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  final env = DotEnv()..load(['.env']);
  final url = env['SUPABASE_URL'] ?? '';
  final key =
      env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? '';

  if (url.isEmpty || key.isEmpty) {
    print('Error: SUPABASE_URL or keys not found in .env');
    exit(1);
  }

  print('Connecting to Supabase...');
  // ignore: unused_local_variable
  final client = SupabaseClient(url, key);

  print('Running migration: Add fcm_token to tenants');
  try {
    // We can't run arbitrary SQL through the client easily without a function.
    // However, we can use the RPC if we have one, or just try to update a row with a dummy value to see if column exists.
    // Alternatively, we can use the HTTP API if we have the service role key.

    print('Migration should be run manually in Supabase SQL Editor:');
    print('ALTER TABLE tenants ADD COLUMN IF NOT EXISTS fcm_token TEXT;');

    exit(0);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
