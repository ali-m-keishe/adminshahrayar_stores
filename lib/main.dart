import 'package:adminshahrayar/screens/main_screen.dart';
import 'package:adminshahrayar/theme.dart';
import 'package:adminshahrayar/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import the Riverpod package
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple ValueNotifier to manage theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ehcesxotispspagreksv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoY2VzeG90aXNwc3BhZ3Jla3N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MjQyNDQsImV4cCI6MjA3MDUwMDI0NH0.RGPOSubglmc7ruhm_q6oQDGMA-VNUzg4eyqvo8MQ1FU',
  );

  // 2. Wrap your root widget, SavorAdminApp, in a ProviderScope
  runApp(const ProviderScope(child: SavorAdminApp()));
}

class SavorAdminApp extends StatelessWidget {
  const SavorAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SavorAdmin Pro - Restaurant Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
