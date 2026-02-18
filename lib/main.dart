import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/services/backend_config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration (Mock vs Real)
  await BackendConfig.initialize();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase for direct real-time updates
  await Supabase.initialize(
    url: BackendConfig.supabaseUrl,
    anonKey: BackendConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyOfficeHubApp()));
}
