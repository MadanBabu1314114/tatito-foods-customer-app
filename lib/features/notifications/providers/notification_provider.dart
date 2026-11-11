import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../models/app_notification.dart';

/// In-app notification inbox. Email/SMS/background delivery will be added when
/// the real API is connected.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    _load();
  }

  static const String _storageKey = 'tatito_notifications_v1';

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> _load() async {
    final raw = await LocalStore.readJson(_storageKey);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _notifications.add(
            AppNotification.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    } else {
      final now = DateTime.now();
      _notifications.addAll([
        AppNotification(
          id: 'notification-seed-1',
          title: 'Order delivered',
          body: 'Order #1042 was delivered. Tell us how it went!',
          createdAt: now.subtract(const Duration(days: 3)),
          isRead: true,
          orderId: 1042,
        ),
        AppNotification(
          id: 'notification-seed-2',
          title: 'Order placed',
          body: 'Order #1045 is placed. Complete the online payment to confirm.',
          createdAt: now.subtract(const Duration(hours: 5)),
          orderId: 1045,
        ),
      ]);
      await _persist();
    }
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> add({
    required String title,
    required String body,
    int? orderId,
  }) async {
    _notifications.insert(
      0,
      AppNotification(
        id: 'notification-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        orderId: orderId,
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (var index = 0; index < _notifications.length; index++) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await LocalStore.writeJson(
      _storageKey,
      _notifications.map((notification) => notification.toJson()).toList(),
    );
  }
}
