// lib/data/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔹 Sign in with email and password, then check if user is admin
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      print('🔐 Attempting to sign in: $email');
      
      // 1. Sign in with Supabase
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'error': 'Failed to sign in. Please try again.',
        };
      }

      final userId = response.user!.id;
      print('✅ Signed in successfully. User ID: $userId');

      // 2. Check if user is admin using database function (bypasses RLS)
      bool isAdmin = false;
      try {
        final result = await _client.rpc(
          'check_user_is_admin',
          params: {'user_uuid': userId},
        );
        isAdmin = result as bool? ?? false;
        print('👤 Is Admin (from function): $isAdmin');
      } catch (e) {
        // Fallback to direct table query if function doesn't exist
        print('⚠️ Function not available, trying direct query: $e');
        try {
          final roleResponse = await _client
              .from('user_roles')
              .select('role')
              .eq('user_id', userId)
              .maybeSingle();

          print('📋 Role check result: $roleResponse');

          if (roleResponse != null) {
            final role = roleResponse['role'];
            if (role != null) {
              final roleString = role.toString().toLowerCase();
              isAdmin = roleString == 'admin';
              print('👤 User role: $role, Is Admin: $isAdmin');
            }
          }
        } catch (fallbackError) {
          print('❌ Both function and direct query failed: $fallbackError');
          // If both fail, assume not admin for security
          isAdmin = false;
        }
      }

      if (!isAdmin) {
        // Sign out if not admin
        await _client.auth.signOut();
        return {
          'success': false,
          'error': 'Access denied. Admin privileges required.',
        };
      }

      return {
        'success': true,
        'userId': userId,
        'userEmail': response.user!.email ?? email,
        'isAdmin': isAdmin,
      };
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      return {
        'success': false,
        'error': e.message,
      };
    } on PostgrestException catch (e) {
      print('❌ Database error during sign in: ${e.message}');
      print('Error code: ${e.code}');
      if (e.code == '42501' || e.code == '403') {
        return {
          'success': false,
          'error': 'Permission denied. Please contact administrator to set up user roles permissions.',
        };
      }
      return {
        'success': false,
        'error': 'Database error. Please try again.',
      };
    } catch (e, stack) {
      print('❌ Unexpected error during sign in: $e');
      print(stack);
      return {
        'success': false,
        'error': 'An error occurred. Please try again.',
      };
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');
      await _client.auth.signOut();
      print('✅ Signed out successfully');
    } catch (e, stack) {
      print('❌ Error signing out: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// 🔹 Check if current user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  /// 🔹 Check if current user is admin
  Future<bool> checkIsAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Try using database function first (more reliable)
      try {
        final result = await _client.rpc(
          'check_user_is_admin',
          params: {'user_uuid': user.id},
        );
        return result as bool? ?? false;
      } catch (e) {
        // Fallback to direct table query
        print('⚠️ Function not available, trying direct query: $e');
        final roleResponse = await _client
            .from('user_roles')
            .select('role')
            .eq('user_id', user.id)
            .maybeSingle();

        if (roleResponse != null) {
          final role = roleResponse['role'];
          if (role != null) {
            final roleString = role.toString().toLowerCase();
            return roleString == 'admin';
          }
        }
        return false;
      }
    } on PostgrestException catch (e) {
      print('❌ Database error checking admin status: ${e.message}');
      print('Error code: ${e.code}');
      if (e.code == '42501' || e.code == '403') {
        print('⚠️ RLS policy issue: Please run SETUP_USER_ROLES_RLS_V2.sql in Supabase SQL Editor');
      }
      return false;
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  /// 🔹 Auth state stream
  Stream get authStateChanges => _client.auth.onAuthStateChange;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
