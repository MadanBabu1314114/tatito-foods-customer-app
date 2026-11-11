import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/food_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../catalog/screens/product_detail_screen.dart';
import '../../payments/screens/payment_screen.dart';
import '../../reviews/providers/review_provider.dart';
import '../../reviews/screens/review_form_screen.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final order = orders.byId(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order details')),
        body: const AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Order not found',
          message: 'This order is not available in the local demo data.',
        ),
      );
    }

    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 130),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Placed ${formatDateTime(order.placedAt)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: TatitoColors.textMuted,
                          ),
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (order.status == OrderStatus.cancelled)
                    const Text(
                      'This order was cancelled. Stock has been restored.',
                      style: TextStyle(
                        color: TatitoColors.dangerRed,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      'Delivery slot: ${order.deliverySlot}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TatitoColors.brandGreenDark,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            title: 'Items',
            child: Column(
              children: order.items
                  .map((item) => _OrderItemRow(item: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            title: 'Delivery address',
            child: Text(
              order.deliveryAddress,
              style: const TextStyle(
                color: TatitoColors.textBody,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            title: 'Payment summary',
            child: Column(
              children: [
                _SummaryLine(
                  label: 'Item total',
                  value: formatMoney(order.subtotal),
                ),
                if (order.discount > 0)
                  _SummaryLine(
                    label: 'Coupon discount${order.couponCode == null ? '' : ' (${order.couponCode})'}',
                    value: '-${formatMoney(order.discount)}',
                    green: true,
                  ),
                _SummaryLine(
                  label: 'Delivery fee',
                  value: formatMoney(order.deliveryFee),
                ),
                const Divider(height: 20),
                _SummaryLine(
                  label: 'Total',
                  value: formatMoney(order.total),
                  bold: true,
                ),
                const SizedBox(height: 6),
                _SummaryLine(
                  label: 'Payment',
                  value:
                      '${order.paymentMethod.label} · ${order.paymentStatus.label}',
                  red: order.paymentStatus == OrderPaymentStatus.failed,
                  green: order.paymentStatus == OrderPaymentStatus.paid ||
                      order.paymentStatus == OrderPaymentStatus.refunded,
                ),
                if (order.status == OrderStatus.cancelled &&
                    order.paymentMethod == OrderPaymentMethod.online &&
                    order.paymentStatus == OrderPaymentStatus.refunded)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Mock refund completed. No real money was charged.',
                      style: TextStyle(
                        fontSize: 12,
                        color: TatitoColors.brandGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _SectionCard(
            title: 'Order timeline',
            child: Column(
              children: order.statusEvents.isEmpty
                  ? [
                      _TimelineRow(
                        label: order.status.label,
                        time: order.placedAt,
                        isLast: true,
                      ),
                    ]
                  : [
                      for (var index = 0;
                          index < order.statusEvents.length;
                          index++)
                        _TimelineRow(
                          label: order.statusEvents[index].status.label,
                          time: order.statusEvents[index].at,
                          isLast: index == order.statusEvents.length - 1,
                        ),
                    ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 10),
            _ReviewShortcuts(order: order, userId: user.id),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TatitoColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (order.status.canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancel(context, order),
                    child: const Text('Cancel order'),
                  ),
                ),
              if (order.status.canCancel) const SizedBox(width: 8),
              if (order.paymentMethod == OrderPaymentMethod.online &&
                  order.status != OrderStatus.cancelled &&
                  order.paymentStatus != OrderPaymentStatus.paid)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(orderId: order.id),
                        ),
                      );
                    },
                    child: const Text('Pay now'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _reorder(context, order),
                    child: const Text('Reorder'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, Order order) async {
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

  void _reorder(BuildContext context, Order order) {
    final result = context.read<OrdersProvider>().reorder(
          order: order,
          cart: context.read<CartProvider>(),
          catalog: context.read<CatalogProvider>(),
        );
    final message = result.added == 0
        ? 'None of these items are available right now.'
        : '${result.added} item(s) added to basket.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItemSnapshot item;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final product = catalog.byId(item.productId);
    final reviewProvider = context.watch<ReviewProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final canReview = reviewProvider.canReview(
      productId: item.productId,
      userId: user?.id,
      orders: context.read<OrdersProvider>(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodBadge(foodType: item.foodType, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.unit} × ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TatitoColors.textMuted,
                  ),
                ),
                if (canReview && product != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final submitted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewFormScreen(product: product),
                        ),
                      );
                      if (submitted == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Review submitted for approval. Thank you!',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Write a review'),
                  ),
              ],
            ),
          ),
          Text(
            formatMoney(item.total),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (product != null)
            IconButton(
              tooltip: 'View product',
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ReviewShortcuts extends StatelessWidget {
  const _ReviewShortcuts({required this.order, required this.userId});

  final Order order;
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (order.status != OrderStatus.delivered) return const SizedBox.shrink();
    final catalog = context.read<CatalogProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final orders = context.read<OrdersProvider>();

    final pending = order.items.where((item) {
      final product = catalog.byId(item.productId);
      return product != null &&
          reviewProvider.canReview(
            productId: item.productId,
            userId: userId,
            orders: orders,
          );
    }).toList();

    if (pending.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Share your experience',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This order was delivered. Reviews help other Tatito families shop with confidence.',
            style: TextStyle(fontSize: 13, color: TatitoColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: pending.map((item) {
              final product = catalog.byId(item.productId);
              if (product == null) return const SizedBox.shrink();
              return OutlinedButton(
                onPressed: () async {
                  final submitted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewFormScreen(product: product),
                    ),
                  );
                  if (submitted == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Review submitted for approval. Thank you!',
                        ),
                      ),
                    );
                  }
                },
                child: Text('Review ${item.name}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TatitoColors.brandBlack,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
    this.green = false,
    this.red = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool green;
  final bool red;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: TatitoColors.textBody,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: red
                    ? TatitoColors.dangerRed
                    : (green ? TatitoColors.brandGreen : null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.time,
    required this.isLast,
  });

  final String label;
  final DateTime time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: TatitoColors.brandGreen,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: TatitoColors.borderSubtle,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  formatDateTime(time),
                  style: const TextStyle(
                    fontSize: 11,
                    color: TatitoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
