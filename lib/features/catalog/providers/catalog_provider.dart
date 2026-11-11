import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/widgets/veg_toggle.dart';
import '../data/mock_catalog_repository.dart';
import '../models/banner_item.dart';
import '../models/catalog_sort.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../utils/product_filters.dart';

/// In-memory catalog for the demo app. Stock changes from local orders are
/// applied here so the whole app stays consistent until it is restarted.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider({MockCatalogRepository? repository})
      : _repository = repository ?? const MockCatalogRepository() {
    _categories = List.of(_repository.categories());
    _products = List.of(_repository.products());
    _banners = List.of(_repository.banners());
  }

  final MockCatalogRepository _repository;
  late final List<ProductCategory> _categories;
  late final List<Product> _products;
  late final List<BannerItem> _banners;

  List<ProductCategory> get categories => List.unmodifiable(_categories);
  List<BannerItem> get banners => List.unmodifiable(_banners);
  List<Product> get allProducts => List.unmodifiable(_products);
  List<Product> get availableProducts =>
      _products.where((product) => product.isAvailable).toList();

  List<Product> get latestProducts {
    final products = _products.where((product) => product.isAvailable).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    return products.take(8).toList();
  }

  List<Product> get organicProducts => _products
      .where((product) => product.isAvailable && product.isOrganic)
      .toList();

  Product? byId(int id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  ProductCategory? categoryById(int id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<Product> productsFor({
    required FoodPreference preference,
    int? categoryId,
    String query = '',
    CatalogSort sort = CatalogSort.newest,
  }) {
    final source = categoryId == null
        ? _products
        : _products.where((product) => product.categoryId == categoryId);
    return filterAndSortProducts(
      source,
      preference: preference,
      query: query,
      sort: sort,
    );
  }

  List<String> suggestionsFor(String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return const [];
    final names = <String>{};
    for (final product in _products.where((product) => product.isAvailable)) {
      if (product.name.toLowerCase().contains(search)) {
        names.add(product.name);
      }
    }
    for (final category in _categories) {
      if (category.name.toLowerCase().contains(search)) {
        names.add(category.name);
      }
    }
    return names.take(6).toList();
  }

  void adjustStock(int productId, int delta) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index == -1) return;
    final nextStock = math.max(0, _products[index].stock + delta);
    _products[index] = _products[index].copyWith(stock: nextStock);
    notifyListeners();
  }

  void decrementForOrder(Map<int, int> quantities) {
    quantities.forEach((productId, quantity) {
      adjustStock(productId, -quantity);
    });
  }

  void restoreForOrder(Map<int, int> quantities) {
    quantities.forEach((productId, quantity) {
      adjustStock(productId, quantity);
    });
  }
}
