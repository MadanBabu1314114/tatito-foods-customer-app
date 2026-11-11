import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatito_customer/features/addresses/data/mock_address_repository.dart';
import 'package:tatito_customer/features/cart/providers/cart_provider.dart';
import 'package:tatito_customer/features/catalog/providers/catalog_provider.dart';
import 'package:tatito_customer/features/checkout/services/checkout_service.dart';
import 'package:tatito_customer/features/orders/models/order_status.dart';
import 'package:tatito_customer/features/orders/providers/orders_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('placing an order clears cart, reduces stock and tracks coupons',
      () async {
    final catalog = CatalogProvider();
    final cart = CartProvider();
    final orders = OrdersProvider();
    await pumpEventQueue();
    orders.attachCatalog(catalog);

    final product = catalog.byId(5)!;
    final initialStock = product.stock;
    cart.addQuantity(product, 2);
    final couponResult = CheckoutService.applyCoupon('FLAT50', cart.subtotal);
    final totals = CheckoutService.totals(
      itemsTotal: cart.subtotal,
      deliveryFee: 0,
      coupon: couponResult.coupon,
    );

    final order = await orders.placeOrder(
      userId: 'customer-demo',
      items: cart.availableItems,
      address: MockAddressRepository().seededAddresses().first,
      slot: CheckoutService.slots.first,
      paymentMethod: OrderPaymentMethod.cod,
      totals: totals,
      cart: cart,
      couponCode: 'FLAT50',
    );

    expect(orders.byId(order.id), isNotNull);
    expect(orders.orders.first.id, order.id);
    expect(cart.availableItems, isEmpty);
    expect(catalog.byId(5)!.stock, initialStock - 2);
    expect(order.discount, 50);
    expect(orders.couponUsage('FLAT50'), 1);
  });

  test('cancelling a paid online order simulates a refund', () async {
    final orders = OrdersProvider();
    await pumpEventQueue();

    await orders.markPaid(1045);
    final cancelled = await orders.cancelOrder(1045);

    expect(cancelled, isTrue);
    expect(orders.byId(1045)!.status, OrderStatus.cancelled);
    expect(
      orders.byId(1045)!.paymentStatus,
      OrderPaymentStatus.refunded,
    );
  });
}
