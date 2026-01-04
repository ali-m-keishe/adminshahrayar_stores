// lib/config/router.dart

import 'package:adminshahrayar_stores/data/models/auth_state.dart';
import 'package:adminshahrayar_stores/main_screen.dart';
import 'package:adminshahrayar_stores/ui/auth/viewmodels/auth_viewmodel.dart';
import 'package:adminshahrayar_stores/ui/auth/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🔹 Router configuration with auth protection
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
    ],
    refreshListenable: _AuthStateNotifier(ref),
  );
});

/// 🔹 Listenable for router refresh when auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final Ref _ref;

  _AuthStateNotifier(this._ref) {
    _ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

