import 'package:flutter_test/flutter_test.dart';
import 'package:tatito_customer/features/catalog/providers/catalog_provider.dart';

void main() {
  test('adjustStock updates the provider-owned product list', () {
    final catalog = CatalogProvider();
    final product = catalog.byId(1)!;
    final initialStock = product.stock;

    catalog.adjustStock(1, -2);

    expect(catalog.byId(1)!.stock, initialStock - 2);
  });

  test('stock never becomes negative', () {
    final catalog = CatalogProvider();
    final product = catalog.byId(1)!;

    catalog.adjustStock(1, -product.stock - 5);

    expect(catalog.byId(1)!.stock, 0);
    expect(catalog.byId(1)!.isAvailable, isFalse);
  });
}
