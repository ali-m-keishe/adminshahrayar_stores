import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  NotificationRepository({
    SupabaseClient? supabaseClient,
    http.Client? httpClient,
    String? serverKey,
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        _httpClient = httpClient ?? http.Client(),
        _serverKey =
            serverKey ?? const String.fromEnvironment('FCM_SERVER_KEY');

  final SupabaseClient _supabase;
  final http.Client _httpClient;
  final String _serverKey;

  static const _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  /// Send a notification via FCM to all tokens stored in Supabase `user_tokens` table.
  Future<void> sendNotification({
    required String title,
    required String content,
  }) async {
   
    try {
      /// Insert the notification into the Supabase `notifications` table.
      await _supabase.from('notifications').insert({
        'title': title,
        'body': content,
        'user_id': null, // أو ضع user_id لو بدك تربطها بمستخدم معيّن
      });

      
     
    } on TimeoutException catch (e) {
      throw Exception('Request timeout while contacting FCM: $e');
    } catch (e) {
      rethrow;
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});
