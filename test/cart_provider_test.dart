import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatito_customer/core/widgets/food_badge.dart';
import 'package:tatito_customer/features/cart/models/cart_item.dart';
import 'package:tatito_customer/features/cart/providers/cart_provider.dart';
import 'package:tatito_customer/features/catalog/models/product.dart';

const _tomato = Product(
  id: 1,
  categoryId: 1,
  name: 'Tomato',
  slug: 'tomato',
  description: 'Fresh tomato',
  foodType: FoodType.veg,
  price: 40,
  mrp: 50,
  unit: '1 kg',
  stock: 3,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('caps quantities at available stock', () {
    final cart = CartProvider();

    cart.addQuantity(_tomato, 10);

    expect(cart.getQuantity(1), 3);
    expect(cart.subtotal, 120);
    expect(cart.totalSavings, 30);
  });

  test('moves out-of-stock lines out of available totals', () {
    final cart = CartProvider();
    cart.addQuantity(_tomato, 2);

    cart.syncWithCatalog([_tomato.copyWith(stock: 0)]);

    expect(cart.availableItems, isEmpty);
    expect(cart.unavailableItems, hasLength(1));
    expect(cart.totalItemCount, 0);
    expect(cart.subtotal, 0);
    expect(cart.hasUnavailableItems, isTrue);
  });

  test('merges guest lines without exceeding stock', () {
    final cart = CartProvider();
    cart.addQuantity(_tomato, 2);

    cart.mergeItems([CartItem(product: _tomato, quantity: 2)]);

    expect(cart.getQuantity(1), 3);
  });
}
