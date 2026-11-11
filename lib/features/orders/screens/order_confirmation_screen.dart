import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../models/order_status.dart';
import '../providers/orders_provider.dart';
import 'order_detail_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    final isCod = order.paymentMethod == OrderPaymentMethod.cod;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: TatitoColors.brandGreenLight,
              child: Icon(
                Icons.check_circle,
                size: 58,
                color: TatitoColors.brandGreen,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Thank you for your order!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TatitoColors.brandBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCod
                ? 'Your order is placed. Please keep ${formatMoney(order.total)} ready at delivery.'
                : 'Your payment is confirmed. We will start packing your order shortly.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TatitoColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Order number', value: '#${order.id}'),
                  _InfoRow(
                    label: 'Items',
                    value: '${order.itemCount} item(s)',
                  ),
                  _InfoRow(
                    label: 'Delivery slot',
                    value: order.deliverySlot,
                  ),
                  _InfoRow(
                    label: 'Payment',
                    value: '${order.paymentMethod.label} · ${order.paymentStatus.label}',
                  ),
                  const Divider(height: 22),
                  _InfoRow(
                    label: 'Total',
                    value: formatMoney(order.total),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: order.id),
                ),
              );
            },
            child: const Text('View order details'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Continue shopping'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: TatitoColors.textMuted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: TatitoColors.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
