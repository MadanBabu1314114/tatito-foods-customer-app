import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/food_badge.dart';
import '../../catalog/models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartStorageKey = 'tatito_guest_cart_items';
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};
  List<CartItem> get itemList => _items.values.toList();

  /// Lines that are still active and in stock.
  List<CartItem> get availableItems =>
      _items.values.where((item) => item.product.isAvailable).toList();

  /// Lines kept in the basket but excluded from totals and checkout.
  List<CartItem> get unavailableItems =>
      _items.values.where((item) => !item.product.isAvailable).toList();

  bool get hasUnavailableItems => unavailableItems.isNotEmpty;

  int get totalItemCount {
    return availableItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return availableItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get totalSavings {
    return availableItems.fold(0.0, (sum, item) => sum + item.savings);
  }

  bool get isEmpty => availableItems.isEmpty;

  /// Check if the basket contains both Veg and Non-Veg items.
  bool get hasMixedVegNonVeg {
    bool hasVeg = false;
    bool hasNonVeg = false;

    for (final item in availableItems) {
      if (item.product.foodType == FoodType.veg) hasVeg = true;
      if (item.product.foodType == FoodType.nonVeg) hasNonVeg = true;
      if (hasVeg && hasNonVeg) return true;
    }
    return false;
  }

  CartProvider() {
    _loadFromStorage();
  }

  int getQuantity(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void addItem(Product product) {
    addQuantity(product, 1);
  }

  /// Adds up to the live stock limit and never creates an unavailable line.
  void addQuantity(Product product, int quantity) {
    if (!product.isAvailable || quantity <= 0) return;
    final current = _items[product.id];
    if (current != null) {
      current.product = product;
      current.quantity = math.min(current.quantity + quantity, product.stock);
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: math.min(quantity, product.stock),
      );
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeOne(Product product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    _saveToStorage();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }

  /// Refreshes cart product snapshots after stock/catalog changes.
  void syncWithCatalog(Iterable<Product> products) {
    final byId = {for (final product in products) product.id: product};
    for (final entry in _items.entries) {
      final latest = byId[entry.key];
      if (latest != null) {
        entry.value.product = latest;
      }
    }
    notifyListeners();
  }

  /// Used when a guest cart is attached to a signed-in account.
  void mergeItems(Iterable<CartItem> guestItems) {
    for (final item in guestItems) {
      addQuantity(item.product, item.quantity);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.values.map((item) => item.toJson()).toList();
      await prefs.setString(_cartStorageKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cartStorageKey);
      if (data != null) {
        final decoded = jsonDecode(data) as List<dynamic>;
        _items.clear();
        for (final itemJson in decoded) {
          final item = CartItem.fromJson(itemJson as Map<String, dynamic>);
          _items[item.product.id] = item;
        }
        notifyListeners();
      }
    } catch (_) {}
  }
}
