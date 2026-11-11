import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/food_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/sign_in_screen.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My basket'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.itemList.isEmpty
          ? AppEmptyState(
              icon: Icons.shopping_basket_outlined,
              title: 'Your basket is empty',
              message:
                  'Explore fresh vegetables, fruits, groceries and daily essentials to fill your basket.',
              action: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Browse products'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
              children: [
                if (cart.hasUnavailableItems) _UnavailableNotice(cart: cart),
                if (cart.hasMixedVegNonVeg) const _MixedCartNotice(),
                Card(
                  child: Column(
                    children: [
                      for (final item in cart.availableItems)
                        _CartItemTile(item: item, cart: cart),
                      for (final item in cart.unavailableItems)
                        _UnavailableCartTile(item: item, cart: cart),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _BillCard(cart: cart),
                const SizedBox(height: 14),
                const _CancellationNotice(),
              ],
            ),
      bottomNavigationBar: cart.itemList.isEmpty
          ? null
          : _CheckoutBar(cart: cart),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear basket?'),
        content: const Text(
          'Are you sure you want to remove all items from your basket?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TatitoColors.dangerRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cart.clearCart();
    }
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.cart});

  final CartItem item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          FoodBadge(foodType: item.product.foodType),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TatitoColors.brandBlack,
                  ),
                ),
                Text(
                  item.product.unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TatitoColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(item.product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TatitoColors.brandBlack,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: TatitoColors.brandGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 26, minHeight: 30),
                  icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                  onPressed: () => cart.removeOne(item.product),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 26, minHeight: 30),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  onPressed: () => cart.addItem(item.product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableCartTile extends StatelessWidget {
  const _UnavailableCartTile({required this.item, required this.cart});

  final CartItem item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.block, color: TatitoColors.textMuted),
      title: Text(
        item.product.name,
        style: const TextStyle(color: TatitoColors.textMuted),
      ),
      subtitle: const Text(
        'No longer available · excluded from total',
        style: TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => cart.removeItem(item.product.id),
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TatitoColors.warningOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: TatitoColors.warningOrange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Some items are unavailable and are not included in your total.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
          TextButton(
            onPressed: () {
              for (final item in cart.unavailableItems) {
                cart.removeItem(item.product.id);
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _MixedCartNotice extends StatelessWidget {
  const _MixedCartNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TatitoColors.warningOrange.withValues(alpha: 0.5),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco_rounded, color: TatitoColors.vegGreen, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your basket has both Veg & Non-Veg items. Tatito Foods packs them in separate, sealed hygienic bags.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 22),
            _BillRow(label: 'Item total', value: formatMoney(cart.subtotal)),
            if (cart.totalSavings > 0) ...[
              const SizedBox(height: 8),
              _BillRow(
                label: 'Savings',
                value: '-${formatMoney(cart.totalSavings)}',
                isGreen: true,
              ),
            ],
            const SizedBox(height: 8),
            const _BillRow(
              label: 'Delivery fee',
              value: 'Calculated at checkout',
              small: true,
            ),
            const Divider(height: 22),
            _BillRow(
              label: 'Items to pay',
              value: formatMoney(cart.subtotal),
              isBold: true,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.isGreen = false,
    this.isBold = false,
    this.small = false,
    this.fontSize = 14,
  });

  final String label;
  final String value;
  final bool isGreen;
  final bool isBold;
  final bool small;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: small ? 12 : fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? TatitoColors.brandBlack : TatitoColors.textBody,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 12 : fontSize,
            fontWeight: FontWeight.w600,
            color: isGreen
                ? TatitoColors.brandGreen
                : (isBold ? TatitoColors.brandBlack : TatitoColors.textBody),
          ),
        ),
      ],
    );
  }
}

class _CancellationNotice extends StatelessWidget {
  const _CancellationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TatitoColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TatitoColors.borderSubtle),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: TatitoColors.textMuted,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Orders can be cancelled before packing. In-stock items will be reserved immediately.',
              style: TextStyle(fontSize: 12, color: TatitoColors.textBody),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});

  final CartProvider cart;

  Future<void> _openCheckout(BuildContext context) async {
    if (cart.availableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available items to check out.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      final signedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
      if (signedIn != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ITEM TOTAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TatitoColors.textMuted,
                  ),
                ),
                Text(
                  formatMoney(cart.subtotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TatitoColors.brandBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openCheckout(context),
                child: const Text('Proceed to checkout →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
