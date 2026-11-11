import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../../addresses/models/address.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../checkout/models/delivery_slot.dart';
import '../../checkout/services/checkout_service.dart';
import '../../notifications/providers/notification_provider.dart';
import '../data/mock_orders_repository.dart';
import '../models/order.dart';
import '../models/order_status.dart';

class ReorderResult {
  const ReorderResult({
    required this.added,
    required this.skipped,
    required this.capped,
  });

  final int added;
  final int skipped;
  final int capped;
}

/// Local order history and lifecycle. Stock and notifications are updated here
/// so the whole demo remains consistent without a backend.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider({MockOrdersRepository? repository})
      : _repository = repository ?? const MockOrdersRepository() {
    _load();
  }

  static const String _storageKey = 'tatito_orders_v1';

  final MockOrdersRepository _repository;
  final List<Order> _orders = [];
  final Map<String, int> _couponUsage = {};
  CatalogProvider? _catalog;
  NotificationProvider? _notifications;

  bool _loading = true;
  bool get isLoading => _loading;

  List<Order> get orders {
    final sorted = [..._orders]
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List.unmodifiable(sorted);
  }

  void attachCatalog(CatalogProvider catalog) {
    _catalog = catalog;
  }

  void attachNotifications(NotificationProvider notifications) {
    _notifications = notifications;
  }

  Order? byId(int id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  int couponUsage(String code) => _couponUsage[code.toUpperCase()] ?? 0;

  Future<void> _load() async {
    final raw = await LocalStore.readJson(_storageKey);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _orders.add(
            Order.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    } else {
      _orders.addAll(_repository.seededOrders());
      await _persist();
    }
    _rebuildCouponUsage();
    _loading = false;
    notifyListeners();
  }

  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address address,
    required DeliverySlot slot,
    required OrderPaymentMethod paymentMethod,
    required CheckoutTotals totals,
    required CartProvider cart,
    String? couponCode,
  }) async {
    final now = DateTime.now();
    final nextId = _orders.isEmpty
        ? 1001
        : _orders
                .map((order) => order.id)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final snapshots = items
        .map(
          (item) => OrderItemSnapshot(
            productId: item.product.id,
            name: item.product.name,
            unit: item.product.unit,
            price: item.product.price,
            quantity: item.quantity,
            foodType: item.product.foodType,
          ),
        )
        .toList();

    final order = Order(
      id: nextId,
      userId: userId,
      placedAt: now,
      status: OrderStatus.placed,
      paymentMethod: paymentMethod,
      paymentStatus: OrderPaymentStatus.pending,
      items: snapshots,
      deliveryAddress: address.singleLine,
      deliverySlot: slot.label,
      subtotal: totals.itemsTotal,
      discount: totals.discount,
      deliveryFee: totals.deliveryFee,
      total: totals.total,
      statusEvents: [OrderStatusEvent(status: OrderStatus.placed, at: now)],
      couponCode: couponCode,
    );

    _orders.insert(0, order);
    _catalog?.decrementForOrder(order.quantityByProduct);
    cart.clearCart();
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      final code = couponCode.trim().toUpperCase();
      _couponUsage[code] = (_couponUsage[code] ?? 0) + 1;
    }
    await _notifications?.add(
      title: 'Order placed',
      body: paymentMethod == OrderPaymentMethod.online
          ? 'Order #$nextId is placed. Complete the online payment to confirm it.'
          : 'Order #$nextId is placed. You can track it from My Orders.',
      orderId: nextId,
    );
    await _persist();
    notifyListeners();
    return order;
  }

  Future<void> markPaid(int orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(
      paymentStatus: OrderPaymentStatus.paid,
    );
    await _notifications?.add(
      title: 'Payment confirmed',
      body: 'Payment for order #$orderId was confirmed successfully.',
      orderId: orderId,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> markPaymentFailed(int orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(
      paymentStatus: OrderPaymentStatus.failed,
    );
    await _persist();
    notifyListeners();
  }

  Future<bool> cancelOrder(int orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return false;
    final order = _orders[index];
    if (!order.status.canCancel) return false;

    final now = DateTime.now();
    final refundDue = order.paymentMethod == OrderPaymentMethod.online &&
        order.paymentStatus == OrderPaymentStatus.paid;
    _orders[index] = order.copyWith(
      status: OrderStatus.cancelled,
      paymentStatus:
          refundDue ? OrderPaymentStatus.refunded : order.paymentStatus,
      statusEvents: [
        ...order.statusEvents,
        OrderStatusEvent(status: OrderStatus.cancelled, at: now),
      ],
    );
    _catalog?.restoreForOrder(order.quantityByProduct);
    final coupon = order.couponCode?.toUpperCase();
    if (coupon != null && (_couponUsage[coupon] ?? 0) > 0) {
      _couponUsage[coupon] = _couponUsage[coupon]! - 1;
    }
    await _notifications?.add(
      title: 'Order cancelled',
      body: refundDue
          ? 'Order #$orderId was cancelled. A mock refund was processed and stock was restored.'
          : 'Order #$orderId was cancelled. Stock and coupon usage were restored.',
      orderId: orderId,
    );
    await _persist();
    notifyListeners();
    return true;
  }

  ReorderResult reorder({
    required Order order,
    required CartProvider cart,
    required CatalogProvider catalog,
  }) {
    var added = 0;
    var skipped = 0;
    var capped = 0;

    for (final item in order.items) {
      final product = catalog.byId(item.productId);
      if (product == null || !product.isAvailable) {
        skipped++;
        continue;
      }
      final available = math.min(item.quantity, product.stock);
      if (available <= 0) {
        skipped++;
        continue;
      }
      cart.addQuantity(product, available);
      added += available;
      if (available < item.quantity) capped++;
    }
    return ReorderResult(added: added, skipped: skipped, capped: capped);
  }

  bool hasDeliveredProduct({
    required String userId,
    required int productId,
  }) {
    return _orders.any(
      (order) =>
          order.userId == userId &&
          order.status == OrderStatus.delivered &&
          order.items.any((item) => item.productId == productId),
    );
  }

  void _rebuildCouponUsage() {
    _couponUsage.clear();
    for (final order in _orders) {
      if (order.status == OrderStatus.cancelled) continue;
      final code = order.couponCode?.toUpperCase();
      if (code == null || code.isEmpty) continue;
      _couponUsage[code] = (_couponUsage[code] ?? 0) + 1;
    }
  }

  Future<void> _persist() async {
    await LocalStore.writeJson(
      _storageKey,
      _orders.map((order) => order.toJson()).toList(),
    );
  }
}
