import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';

/// Local wishlist keyed by product id. The UI gates it behind sign-in.
class WishlistProvider extends ChangeNotifier {
  WishlistProvider() {
    _load();
  }

  static const String _storageKey = 'tatito_wishlist_v1';

  final Set<int> _productIds = {};

  Set<int> get productIds => Set.unmodifiable(_productIds);
  int get count => _productIds.length;
  bool contains(int productId) => _productIds.contains(productId);

  Future<void> toggle(int productId) async {
    if (_productIds.contains(productId)) {
      _productIds.remove(productId);
    } else {
      _productIds.add(productId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await LocalStore.readJson(_storageKey);
    if (raw is List) {
      _productIds
        ..clear()
        ..addAll(raw.whereType<num>().map((value) => value.toInt()));
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await LocalStore.writeJson(_storageKey, _productIds.toList());
  }
}
