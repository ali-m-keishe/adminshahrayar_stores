import 'package:adminshahrayar_stores/ui/notifications/viewmodels/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendNotificationPage extends ConsumerStatefulWidget {
  const SendNotificationPage({super.key});

  @override
  ConsumerState<SendNotificationPage> createState() =>
      _SendNotificationPageState();
}

class _SendNotificationPageState extends ConsumerState<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    // Unfocus any text fields to prevent keyboard issues
    FocusScope.of(context).unfocus();
    
    if (!_formKey.currentState!.validate()) return;

    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(notificationViewModelProvider).sendNotification(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      _titleController.clear();
      _contentController.clear();
    } catch (e, stackTrace) {
      print('Error in _handleSend: $e');
      print('Stack trace: $stackTrace');
      
      if (!mounted) return;

      // Extract a user-friendly error message
      String errorMessage = 'Failed to send notification';
      if (e is Exception) {
        final errorStr = e.toString();
        if (errorStr.contains('Network error')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorStr.contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        } else if (errorStr.contains('Edge Function error')) {
          errorMessage = 'Server error. Please check the function logs.';
        } else {
          // Extract the actual error message if available
          final match = RegExp(r'Failed to send notification: (.+)').firstMatch(errorStr);
          errorMessage = match != null ? match.group(1)! : errorStr;
        }
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF010A1F) : theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                    : [Colors.white, const Color(0xFFF3F4F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Send Notification',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share important updates with your customers instantly.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Notification Title',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.blueGrey[200]
                              : Colors.grey.withOpacity(0.8),
                        ),
                        prefixIcon: const Icon(Icons.title_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.shade100,
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        // Move focus to content field on Enter
                        FocusScope.of(context).nextFocus();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contentController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Notification Content',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.blueGrey[200]
                              : Colors.grey.withOpacity(0.8),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 80.0),
                          child: Icon(Icons.short_text_rounded),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.shade100,
                      ),
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the notification message';
                        }
                        if (value.trim().length < 20) {
                          return 'Message should be at least 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSend,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isLoading ? 'Sending...' : 'Send Notification',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 8,
                      ),
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


