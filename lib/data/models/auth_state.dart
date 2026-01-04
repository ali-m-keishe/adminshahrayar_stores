// lib/data/models/auth_state.dart

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? userId;
  final String? userEmail;
  final bool isAdmin;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.userId,
    this.userEmail,
    this.isAdmin = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? userId,
    String? userEmail,
    bool? isAdmin,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  // Clear error
  AuthState clearError() {
    return copyWith(error: null);
  }

  // Initial state
  factory AuthState.initial() {
    return const AuthState();
  }

  // Loading state
  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  // Authenticated state
  factory AuthState.authenticated({
    required String userId,
    required String userEmail,
    required bool isAdmin,
  }) {
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      userId: userId,
      userEmail: userEmail,
      isAdmin: isAdmin,
    );
  }

  // Error state
  factory AuthState.error(String error) {
    return AuthState(
      isLoading: false,
      isAuthenticated: false,
      error: error,
    );
  }
}

