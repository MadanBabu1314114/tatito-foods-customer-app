import '../../../core/widgets/food_badge.dart';
import '../models/order.dart';
import '../models/order_status.dart';

/// Seeded order history so reviews, reorder and order screens are usable
/// before real order APIs are connected.
class MockOrdersRepository {
  const MockOrdersRepository();

  List<Order> seededOrders() {
    final now = DateTime.now();
    final deliveredAt = now.subtract(const Duration(days: 3));
    final placedAt = now.subtract(const Duration(days: 3, hours: 2));

    return [
      Order(
        id: 1042,
        userId: 'customer-demo',
        placedAt: placedAt,
        status: OrderStatus.delivered,
        paymentMethod: OrderPaymentMethod.cod,
        paymentStatus: OrderPaymentStatus.paid,
        items: const [
          OrderItemSnapshot(
            productId: 1,
            name: 'Fresh Farm Tomatoes (Local)',
            unit: '1 kg',
            price: 38,
            quantity: 2,
            foodType: FoodType.veg,
          ),
          OrderItemSnapshot(
            productId: 5,
            name: 'Pure Organic Honey (Unprocessed)',
            unit: '500 g',
            price: 320,
            quantity: 1,
            foodType: FoodType.veg,
          ),
        ],
        deliveryAddress:
            'Flat 402, Green Meadows, Madhapur, Hyderabad, Telangana, 500081',
        deliverySlot: '6:00 PM - 8:00 PM',
        subtotal: 396,
        discount: 0,
        deliveryFee: 0,
        total: 396,
        statusEvents: [
          OrderStatusEvent(status: OrderStatus.placed, at: placedAt),
          OrderStatusEvent(
            status: OrderStatus.confirmed,
            at: placedAt.add(const Duration(minutes: 20)),
          ),
          OrderStatusEvent(
            status: OrderStatus.packed,
            at: placedAt.add(const Duration(minutes: 55)),
          ),
          OrderStatusEvent(
            status: OrderStatus.outForDelivery,
            at: placedAt.add(const Duration(hours: 1, minutes: 20)),
          ),
          OrderStatusEvent(status: OrderStatus.delivered, at: deliveredAt),
        ],
      ),
      Order(
        id: 1045,
        userId: 'customer-demo',
        placedAt: now.subtract(const Duration(hours: 5)),
        status: OrderStatus.placed,
        paymentMethod: OrderPaymentMethod.online,
        paymentStatus: OrderPaymentStatus.pending,
        items: const [
          OrderItemSnapshot(
            productId: 3,
            name: 'Fresh Tender Chicken Breast (Boneless)',
            unit: '500 g',
            price: 240,
            quantity: 1,
            foodType: FoodType.nonVeg,
          ),
          OrderItemSnapshot(
            productId: 8,
            name: 'Farm Fresh Toned Milk',
            unit: '500 ml',
            price: 28,
            quantity: 2,
            foodType: FoodType.veg,
          ),
        ],
        deliveryAddress:
            'Flat 402, Green Meadows, Madhapur, Hyderabad, Telangana, 500081',
        deliverySlot: '7:00 PM - 9:00 PM',
        subtotal: 296,
        discount: 29.6,
        deliveryFee: 0,
        total: 266.4,
        couponCode: 'WELCOME10',
        statusEvents: [
          OrderStatusEvent(
            status: OrderStatus.placed,
            at: now.subtract(const Duration(hours: 5)),
          ),
        ],
      ),
      Order(
        id: 1038,
        userId: 'customer-demo',
        placedAt: now.subtract(const Duration(days: 10)),
        status: OrderStatus.cancelled,
        paymentMethod: OrderPaymentMethod.cod,
        paymentStatus: OrderPaymentStatus.pending,
        items: const [
          OrderItemSnapshot(
            productId: 2,
            name: 'Shimla Green Capsicum',
            unit: '500 g',
            price: 45,
            quantity: 2,
            foodType: FoodType.veg,
          ),
        ],
        deliveryAddress:
            'Flat 402, Green Meadows, Madhapur, Hyderabad, Telangana, 500081',
        deliverySlot: '11:00 AM - 1:00 PM',
        subtotal: 90,
        discount: 0,
        deliveryFee: 19,
        total: 109,
        statusEvents: [
          OrderStatusEvent(
            status: OrderStatus.placed,
            at: now.subtract(const Duration(days: 10)),
          ),
          OrderStatusEvent(
            status: OrderStatus.cancelled,
            at: now.subtract(const Duration(days: 10, hours: -1)),
          ),
        ],
      ),
    ];
  }
}
