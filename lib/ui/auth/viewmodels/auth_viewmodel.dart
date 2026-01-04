// lib/ui/auth/viewmodels/auth_viewmodel.dart

import 'package:adminshahrayar_stores/data/models/auth_state.dart';
import 'package:adminshahrayar_stores/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(AuthState.initial()) {
    // Check if user is already authenticated on initialization
    _checkAuthState();
    // Listen to auth state changes
    _listenToAuthChanges();
  }

  /// 🔹 Check current authentication state
  Future<void> _checkAuthState() async {
    if (_authRepository.isAuthenticated()) {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        final isAdmin = await _authRepository.checkIsAdmin();
        if (isAdmin) {
          state = AuthState.authenticated(
            userId: user.id,
            userEmail: user.email ?? '',
            isAdmin: true,
          );
        } else {
          // Not admin, sign out
          await signOut();
        }
      }
    }
  }

  /// 🔹 Listen to auth state changes
  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((authStateChange) {
      // Check the event type using dynamic access since we don't know the exact type
      final event = (authStateChange as dynamic).event;
      if (event != null) {
        final eventString = event.toString();
        if (eventString.contains('signedOut')) {
          state = AuthState.initial();
        } else if (eventString.contains('signedIn')) {
          _checkAuthState();
        }
      }
    });
  }

  /// 🔹 Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    state = AuthState.loading();

    try {
      final result = await _authRepository.signIn(email, password);

      if (result['success'] == true) {
        state = AuthState.authenticated(
          userId: result['userId'] as String,
          userEmail: result['userEmail'] as String,
          isAdmin: result['isAdmin'] as bool,
        );
        return true;
      } else {
        state = AuthState.error(result['error'] as String? ?? 'Sign in failed');
        return false;
      }
    } catch (e) {
      state = AuthState.error('An error occurred: $e');
      return false;
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    try {
      state = AuthState.loading();
      await _authRepository.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error('Error signing out: $e');
    }
  }

  /// 🔹 Clear error
  void clearError() {
    state = state.clearError();
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
