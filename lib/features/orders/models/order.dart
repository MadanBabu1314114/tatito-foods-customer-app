import '../../../core/widgets/food_badge.dart';
import '../models/order_status.dart';

class OrderStatusEvent {
  const OrderStatusEvent({required this.status, required this.at});

  final OrderStatus status;
  final DateTime at;

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) {
    return OrderStatusEvent(
      status: OrderStatusText.fromStorage(json['status'] as String? ?? 'placed'),
      at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.storageValue,
      'at': at.toIso8601String(),
    };
  }
}

class OrderItemSnapshot {
  const OrderItemSnapshot({
    required this.productId,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    this.foodType,
  });

  final int productId;
  final String name;
  final String unit;
  final double price;
  final int quantity;
  final FoodType? foodType;

  double get total => price * quantity;

  factory OrderItemSnapshot.fromJson(Map<String, dynamic> json) {
    FoodType? foodType;
    final value = json['food_type'] as String?;
    if (value == 'veg') foodType = FoodType.veg;
    if (value == 'non_veg') foodType = FoodType.nonVeg;
    return OrderItemSnapshot(
      productId: json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      foodType: foodType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'food_type': foodType == FoodType.veg
          ? 'veg'
          : (foodType == FoodType.nonVeg ? 'non_veg' : null),
    };
  }
}

class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.placedAt,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.items,
    required this.deliveryAddress,
    required this.deliverySlot,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.statusEvents,
    this.couponCode,
  });

  final int id;
  final String userId;
  final DateTime placedAt;
  final OrderStatus status;
  final OrderPaymentMethod paymentMethod;
  final OrderPaymentStatus paymentStatus;
  final List<OrderItemSnapshot> items;
  final String deliveryAddress;
  final String deliverySlot;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final List<OrderStatusEvent> statusEvents;
  final String? couponCode;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<int, int> get quantityByProduct {
    final result = <int, int>{};
    for (final item in items) {
      result[item.productId] = (result[item.productId] ?? 0) + item.quantity;
    }
    return result;
  }

  Order copyWith({
    OrderStatus? status,
    OrderPaymentStatus? paymentStatus,
    List<OrderStatusEvent>? statusEvents,
  }) {
    return Order(
      id: id,
      userId: userId,
      placedAt: placedAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      items: items,
      deliveryAddress: deliveryAddress,
      deliverySlot: deliverySlot,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      statusEvents: statusEvents ?? this.statusEvents,
      couponCode: couponCode,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      placedAt: DateTime.tryParse(json['placed_at'] as String? ?? '') ??
          DateTime.now(),
      status: OrderStatusText.fromStorage(json['status'] as String? ?? 'placed'),
      paymentMethod: OrderPaymentMethodText.fromStorage(
        json['payment_method'] as String? ?? 'cod',
      ),
      paymentStatus: OrderPaymentStatusText.fromStorage(
        json['payment_status'] as String? ?? 'pending',
      ),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => OrderItemSnapshot.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliverySlot: json['delivery_slot'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      statusEvents: (json['status_events'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (event) => OrderStatusEvent.fromJson(
              event.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
      couponCode: json['coupon_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'placed_at': placedAt.toIso8601String(),
      'status': status.storageValue,
      'payment_method': paymentMethod.name,
      'payment_status': paymentStatus.name,
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'delivery_slot': deliverySlot,
      'subtotal': subtotal,
      'discount': discount,
      'delivery_fee': deliveryFee,
      'total': total,
      'status_events': statusEvents.map((event) => event.toJson()).toList(),
      'coupon_code': couponCode,
    };
  }
}
