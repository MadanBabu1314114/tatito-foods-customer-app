import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../addresses/models/address.dart';
import '../../addresses/models/delivery_zone.dart';
import '../../addresses/providers/address_provider.dart';
import '../../addresses/screens/address_form_screen.dart';
import '../../addresses/screens/address_list_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/models/order_status.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_confirmation_screen.dart';
import '../../payments/screens/payment_screen.dart';
import '../models/coupon.dart';
import '../models/delivery_slot.dart';
import '../services/checkout_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _couponController = TextEditingController();
  int? _selectedAddressId;
  String? _selectedSlotId;
  Coupon? _coupon;
  String? _couponMessage;
  bool _couponError = false;
  bool _placing = false;
  OrderPaymentMethod _paymentMethod = OrderPaymentMethod.cod;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(double subtotal) {
    final result = CheckoutService.applyCoupon(_couponController.text, subtotal);
    setState(() {
      if (result.isValid) {
        _coupon = result.coupon;
        _couponError = false;
        _couponMessage = '${result.coupon!.code} applied.';
      } else {
        _coupon = null;
        _couponError = true;
        _couponMessage = result.error;
      }
    });
  }

  Future<void> _changeAddress() async {
    final selected = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressListScreen(selectable: true),
      ),
    );
    if (selected != null) {
      setState(() => _selectedAddressId = selected.id);
    }
  }

  Future<void> _addAddress() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );
    if (saved == true && mounted) {
      final latest = context.read<AddressProvider>().defaultAddress;
      setState(() => _selectedAddressId = latest?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addresses = context.watch<AddressProvider>();
    final cart = context.watch<CartProvider>();
    final orders = context.read<OrdersProvider>();

    final address = addresses.byId(_selectedAddressId) ?? addresses.defaultAddress;
    final DeliveryZone? zone =
        address == null ? null : addresses.zoneFor(address.pincode);
    final subtotal = cart.subtotal;
    final deliveryFee = zone?.deliveryFee ?? 0;
    final totals = CheckoutService.totals(
      itemsTotal: subtotal,
      deliveryFee: deliveryFee,
      coupon: _coupon,
    );
    final matchingSlots = _selectedSlotId == null
        ? const <DeliverySlot>[]
        : CheckoutService.slots
            .where((item) => item.id == _selectedSlotId)
            .toList();
    final slot = matchingSlots.isEmpty ? null : matchingSlots.first;

    final validationError = _validationError(
      userSignedIn: auth.isAuthenticated,
      cartItems: cart.availableItems.length,
      address: address,
      zone: zone,
      slot: slot,
      subtotal: subtotal,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
        children: [
          _Section(
            title: 'Delivery address',
            child: address == null
                ? OutlinedButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Add delivery address'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: TatitoColors.brandGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${address.label.label} · ${address.pincode}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _changeAddress,
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      Text(
                        address.singleLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: TatitoColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      if (zone == null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Delivery is not available at this pincode yet.',
                          style: TextStyle(
                            color: TatitoColors.dangerRed,
                            fontSize: 12,
                          ),
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Delivery fee ${formatMoney(zone.deliveryFee)} · Minimum order ${formatMoney(zone.minimumOrder)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: TatitoColors.brandGreenDark,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          _Section(
            title: 'Delivery slot',
            child: RadioGroup<String>(
              groupValue: _selectedSlotId,
              onChanged: (value) =>
                  setState(() => _selectedSlotId = value),
              child: Column(
                children: CheckoutService.slots
                    .map(
                      (item) => RadioListTile<String>(
                        value: item.id,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(item.label),
                        enabled: item.isAvailable,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _Section(
            title: 'Coupon',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Enter coupon code',
                          prefixIcon: Icon(Icons.local_offer_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _applyCoupon(subtotal),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if (_couponMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _couponMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _couponError
                          ? TatitoColors.dangerRed
                          : TatitoColors.brandGreen,
                    ),
                  ),
                ],
                if (_coupon != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _coupon = null;
                        _couponMessage = null;
                        _couponController.clear();
                      }),
                      child: const Text('Remove coupon'),
                    ),
                  ),
                const SizedBox(height: 2),
                const Text(
                  'Try WELCOME10, FLAT50 or ORGANIC15. Demo coupons are applied locally.',
                  style: TextStyle(
                    fontSize: 11,
                    color: TatitoColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Payment method',
            child: RadioGroup<OrderPaymentMethod>(
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
              child: Column(
                children: [
                  const RadioListTile<OrderPaymentMethod>(
                    value: OrderPaymentMethod.cod,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Cash on Delivery'),
                  ),
                  const RadioListTile<OrderPaymentMethod>(
                    value: OrderPaymentMethod.online,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Pay Online (mock gateway)'),
                    subtitle: Text(
                      'No real payment is taken in this demo.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: 'Order summary',
            child: Column(
              children: [
                _SummaryRow(label: 'Item total', value: formatMoney(subtotal)),
                if (totals.discount > 0)
                  _SummaryRow(
                    label: 'Coupon discount',
                    value: '-${formatMoney(totals.discount)}',
                    isGreen: true,
                  ),
                _SummaryRow(
                  label: 'Delivery fee',
                  value: formatMoney(totals.deliveryFee),
                ),
                const Divider(height: 22),
                _SummaryRow(
                  label: 'Total',
                  value: formatMoney(totals.total),
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    validationError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TatitoColors.dangerRed,
                    ),
                  ),
                ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TO PAY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: TatitoColors.textMuted,
                        ),
                      ),
                      Text(
                        formatMoney(totals.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: validationError == null && !_placing
                          ? () => _placeOrder(
                                address: address!,
                                zone: zone!,
                                slot: slot!,
                                totals: totals,
                                orders: orders,
                                cart: cart,
                              )
                          : null,
                      child: _placing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Place order'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validationError({
    required bool userSignedIn,
    required int cartItems,
    required Address? address,
    required DeliveryZone? zone,
    required DeliverySlot? slot,
    required double subtotal,
  }) {
    if (!userSignedIn) return 'Sign in to place an order.';
    if (cartItems == 0) return 'Your basket has no available items.';
    if (address == null) return 'Add a delivery address.';
    if (!address.hasContact) {
      return 'Add the receiver name and mobile number to this address.';
    }
    if (zone == null) return 'Delivery is not available at this pincode.';
    if (slot == null) return 'Choose a delivery slot.';
    if (subtotal < zone.minimumOrder) {
      return 'Minimum order for this area is ${formatMoney(zone.minimumOrder)}.';
    }
    return null;
  }

  Future<void> _placeOrder({
    required Address address,
    required DeliveryZone zone,
    required DeliverySlot slot,
    required CheckoutTotals totals,
    required OrdersProvider orders,
    required CartProvider cart,
  }) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _placing = true);
    final order = await orders.placeOrder(
      userId: user.id,
      items: List.of(cart.availableItems),
      address: address,
      slot: slot,
      paymentMethod: _paymentMethod,
      totals: totals,
      cart: cart,
      couponCode: _coupon?.code,
    );
    if (!mounted) return;

    if (_paymentMethod == OrderPaymentMethod.online) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(orderId: order.id),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(orderId: order.id),
        ),
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isGreen = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isGreen;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isGreen ? TatitoColors.brandGreen : null,
            ),
          ),
        ],
      ),
    );
  }
}
