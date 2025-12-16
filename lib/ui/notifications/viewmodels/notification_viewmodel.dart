import 'package:adminshahrayar_stores/data/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for managing notifications
class NotificationViewModel {
  final NotificationRepository _notificationRepository;

  NotificationViewModel(this._notificationRepository);

  /// Send a notification
  Future<void> sendNotification({
    required String title,
    required String content,
  }) async {
    await _notificationRepository.sendNotification(
      title: title,
      content: content,
    );
  }
}

/// Provider for NotificationViewModel
final notificationViewModelProvider =
    Provider<NotificationViewModel>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return NotificationViewModel(repository);
});

