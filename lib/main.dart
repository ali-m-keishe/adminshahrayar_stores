import 'package:adminshahrayar_stores/config/router.dart';
import 'package:adminshahrayar_stores/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Simple ValueNotifier to manage theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qwqxrfseeartwzfmsdcg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cXhyZnNlZWFydHd6Zm1zZGNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTgyNzksImV4cCI6MjA3ODA3NDI3OX0.24Q2TvBzdvexEhCzulK5mPG7AU2wqgyPb7zAR98geFM',
  );

  // Wrap your root widget, SavorAdminApp, in a ProviderScope
  runApp(const ProviderScope(child: SavorAdminApp()));
}

class SavorAdminApp extends ConsumerWidget {
  const SavorAdminApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp.router(
          title: 'SavorAdmin Pro - Restaurant Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          routerConfig: router,
        );
      },
    );
  }
}
