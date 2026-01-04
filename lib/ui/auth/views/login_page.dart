import 'package:adminshahrayar_stores/theme.dart';
import 'package:adminshahrayar_stores/ui/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Navigation will be handled by the router based on auth state
          // No need to manually navigate here
        } else {
          final authState = ref.read(authViewModelProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Clear any previous errors when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentBlue,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                    
                    // Welcome Text
                    Text(
                      'Welcome to our admin page',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SavorAdmin Pro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? AppTheme.bgSecondaryDark 
                            : AppTheme.bgSecondaryLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? AppTheme.borderDark 
                                : AppTheme.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? AppTheme.borderDark 
                                : AppTheme.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.accentBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility_outlined 
                                : Icons.visibility_off_outlined,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? AppTheme.bgSecondaryDark 
                            : AppTheme.bgSecondaryLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? AppTheme.borderDark 
                                : AppTheme.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? AppTheme.borderDark 
                                : AppTheme.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.accentBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Error message display
                    Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authViewModelProvider);
                        if (authState.error != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Login Button
                    Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authViewModelProvider);
                        final isLoading = authState.isLoading;
                        
                        return ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            foregroundColor: AppTheme.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.textWhite,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
