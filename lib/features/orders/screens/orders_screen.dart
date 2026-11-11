import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/sign_in_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../payments/screens/payment_screen.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_badge.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<OrdersProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My orders')),
        body: AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Sign in to view orders',
          message:
              'Your order history, tracking and reorders are available after sign in.',
          action: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            ),
            child: const Text('Sign in'),
          ),
        ),
      );
    }

    final orders = provider.orders
        .where((order) => order.userId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  message:
                      'Your placed orders will appear here with live local status updates.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _OrderCard(order: orders[index]);
                  },
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatDateTime(order.placedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: TatitoColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.items.map((item) => item.name).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: TatitoColors.textBody,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${order.itemCount} item(s) · ${formatMoney(order.total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TatitoColors.brandBlack,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.paymentStatus.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: order.paymentStatus == OrderPaymentStatus.paid
                          ? TatitoColors.brandGreen
                          : (order.paymentStatus ==
                                  OrderPaymentStatus.failed
                              ? TatitoColors.dangerRed
                              : TatitoColors.warningOrange),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () => _openDetails(context),
                    child: const Text('View details'),
                  ),
                  if (order.paymentMethod == OrderPaymentMethod.online &&
                      order.status != OrderStatus.cancelled &&
                      order.paymentStatus != OrderPaymentStatus.paid)
                    TextButton(
                      onPressed: () => _payNow(context),
                      child: const Text('Pay now'),
                    ),
                  if (order.status.canCancel)
                    TextButton(
                      onPressed: () => _cancel(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: TatitoColors.dangerRed),
                      ),
                    ),
                  TextButton(
                    onPressed: () => _reorder(context),
                    child: const Text('Reorder'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order.id),
      ),
    );
  }

  void _payNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(orderId: order.id),
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'Stock and coupon usage will be restored locally. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep order'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TatitoColors.dangerRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<OrdersProvider>().cancelOrder(order.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled.')),
      );
    }
  }

  void _reorder(BuildContext context) {
    final result = context.read<OrdersProvider>().reorder(
          order: order,
          cart: context.read<CartProvider>(),
          catalog: context.read<CatalogProvider>(),
        );
    final message = result.added == 0
        ? 'None of these items are available right now.'
        : '${result.added} item(s) added to basket.${result.skipped > 0 ? ' ${result.skipped} unavailable item(s) skipped.' : ''}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
