import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_notification.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tasks/presentation/task_provider.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationStateRevisionProvider = StateProvider<int>((ref) => 0);

final notificationsFeedProvider = Provider<List<AppNotification>>((ref) {
  ref.watch(taskStateRevisionProvider);
  ref.watch(notificationStateRevisionProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return [];
  return repo.getNotifications(currentUser.id);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  ref.watch(taskStateRevisionProvider);
  ref.watch(notificationStateRevisionProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).valueOrNull;
  if (currentUser == null) return 0;
  return repo.getUnreadCount(currentUser.id);
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

class NotificationActions {
  NotificationActions(this.ref);
  final Ref ref;

  void markAllAsRead() {
    final repo = ref.read(notificationRepositoryProvider);
    repo.markAllAsRead();
    ref.read(notificationStateRevisionProvider.notifier).state++;
  }

  Future<void> deleteNotification(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.deleteNotification(notificationId);
    ref.read(notificationStateRevisionProvider.notifier).state++;
  }
}
