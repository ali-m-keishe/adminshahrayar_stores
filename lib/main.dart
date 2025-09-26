import 'package:adminshahrayar/screens/main_screen.dart';
import 'package:adminshahrayar/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import the Riverpod package

// Simple ValueNotifier to manage theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
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
