import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../models/app_notification.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const AppEmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
              message:
                  'Order updates, payment confirmations and offers will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _NotificationTile(
                  notification: notifications[index],
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  IconData get _icon {
    final title = notification.title.toLowerCase();
    if (title.contains('cancel')) return Icons.cancel_outlined;
    if (title.contains('payment')) return Icons.payments_outlined;
    if (title.contains('deliver')) return Icons.local_shipping_outlined;
    if (title.contains('placed')) return Icons.receipt_long_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final order = notification.orderId == null
        ? null
        : context.read<OrdersProvider>().byId(notification.orderId!);

    return Card(
      margin: EdgeInsets.zero,
      color: notification.isRead ? null : TatitoColors.brandGreenLight,
      child: ListTile(
        onTap: () async {
          await context.read<NotificationProvider>().markRead(notification.id);
          if (!context.mounted) return;
          if (order != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order.id),
              ),
            );
          }
        },
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? TatitoColors.divider
              : TatitoColors.brandGreen,
          child: Icon(
            _icon,
            color: notification.isRead
                ? TatitoColors.textMuted
                : Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.w600
                      : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TatitoColors.brandGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: TatitoColors.textBody,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDateTime(notification.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: TatitoColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: order == null
            ? null
            : const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
