import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../orders/models/order.dart';
import '../../orders/models/order_status.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_confirmation_screen.dart';

/// Simulated payment gateway. No real money is charged and no network call is
/// made; success/failure only updates the locally persisted order.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;
  String? _error;

  Future<void> _pay(Order order) async {
    setState(() {
      _processing = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await context.read<OrdersProvider>().markPaid(order.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(orderId: order.id),
      ),
    );
  }

  Future<void> _simulateFailure(Order order) async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await context.read<OrdersProvider>().markPaymentFailed(order.id);
    if (!mounted) return;
    setState(() {
      _processing = false;
      _error = 'Payment failed. You can retry or pay from My Orders.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    final alreadyPaid = order.paymentStatus == OrderPaymentStatus.paid;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TatitoColors.warningOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.science_outlined, color: TatitoColors.warningOrange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Demo gateway: no real payment is taken. Use the buttons below to simulate success or failure.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 46,
                    color: TatitoColors.brandGreen,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Amount payable',
                    style: TextStyle(color: TatitoColors.textMuted),
                  ),
                  Text(
                    formatMoney(order.total),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: TatitoColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order #${order.id} · ${order.items.length} item(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: TatitoColors.textMuted,
                    ),
                  ),
                  if (alreadyPaid) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'This order is already paid.',
                      style: TextStyle(
                        color: TatitoColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Card(
            child: ListTile(
              leading: Icon(
                Icons.credit_card,
                color: TatitoColors.brandGreen,
              ),
              title: Text('Tatito Pay (mock)'),
              subtitle: Text('UPI, card and netbanking are simulated'),
              trailing: Icon(Icons.check_circle, color: TatitoColors.brandGreen),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TatitoColors.dangerRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _processing || alreadyPaid ? null : () => _pay(order),
            child: _processing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(alreadyPaid ? 'Already paid' : 'Pay ${formatMoney(order.total)}'),
          ),
          if (!alreadyPaid)
            TextButton(
              onPressed: _processing ? null : () => _simulateFailure(order),
              child: const Text('Simulate payment failure'),
            ),
        ],
      ),
    );
  }
}
