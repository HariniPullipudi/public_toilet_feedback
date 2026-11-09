import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/config/supabase_config.dart';
import 'package:cleanspot/screens/auth/splash_screen.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase client if configured
  await SupabaseConfig.initialize();

  // If already logged in, fetch profile
  if (SupabaseConfig.isConfigured &&
      SupabaseConfig.client.auth.currentUser != null) {
    await SupabaseService()
        .fetchUserProfile(SupabaseConfig.client.auth.currentUser!.id);
  }

  runApp(const CleanSpotApp());
}

class CleanSpotApp extends StatelessWidget {
  const CleanSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
