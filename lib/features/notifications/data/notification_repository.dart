import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({MockDataStore? dataStore})
      : _dataStore = dataStore ?? MockDataStore.instance;

  final MockDataStore _dataStore;

  List<AppNotification> getNotifications(String userId) {
    return _dataStore.notifications.where((n) => n.userId == userId).toList();
  }

  int getUnreadCount(String userId) {
    return _dataStore.notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }

  void markAllAsRead() {
    _dataStore.markAllNotificationsAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dataStore.deleteNotification(notificationId);
  }
}
