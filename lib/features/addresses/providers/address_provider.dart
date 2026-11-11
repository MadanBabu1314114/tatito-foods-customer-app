import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../data/mock_address_repository.dart';
import '../models/address.dart';
import '../models/delivery_zone.dart';

/// Locally persisted address book with mock pincode serviceability.
class AddressProvider extends ChangeNotifier {
  AddressProvider({
    MockAddressRepository? repository,
  }) : _repository = repository ?? const MockAddressRepository() {
    _load();
  }

  static const String _storageKey = 'tatito_addresses_v1';

  final MockAddressRepository _repository;
  final List<Address> _addresses = [];
  bool _loading = true;

  bool get isLoading => _loading;
  List<Address> get addresses => List.unmodifiable(_addresses);

  Address? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault) return address;
    }
    return _addresses.isEmpty ? null : _addresses.first;
  }

  Address? byId(String? id) {
    if (id == null) return null;
    for (final address in _addresses) {
      if (address.id == id) return address;
    }
    return null;
  }

  DeliveryZone? zoneFor(String pincode) => _repository.zoneFor(pincode);

  Future<void> _load() async {
    final raw = await LocalStore.readJson(_storageKey);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _addresses.add(
            Address.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    } else {
      _addresses.addAll(_repository.seededAddresses());
      await _persist();
    }
    _ensureSingleDefault();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Address address) async {
    var next = address.copyWith(
      id: 'address-${DateTime.now().millisecondsSinceEpoch}',
    );
    if (_addresses.isEmpty) {
      next = next.copyWith(isDefault: true);
    }
    if (next.isDefault) {
      _clearDefaults();
    }
    _addresses.add(next);
    await _persist();
    notifyListeners();
  }

  Future<void> update(Address address) async {
    final index = _addresses.indexWhere((item) => item.id == address.id);
    if (index == -1) return;
    if (address.isDefault) {
      _clearDefaults();
    }
    _addresses[index] = address;
    _ensureSingleDefault();
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    _ensureSingleDefault();
    await _persist();
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    _clearDefaults();
    final index = _addresses.indexWhere((address) => address.id == id);
    if (index != -1) {
      _addresses[index] = _addresses[index].copyWith(isDefault: true);
    }
    await _persist();
    notifyListeners();
  }

  void _clearDefaults() {
    for (var index = 0; index < _addresses.length; index++) {
      _addresses[index] = _addresses[index].copyWith(isDefault: false);
    }
  }

  void _ensureSingleDefault() {
    if (_addresses.isEmpty) return;
    var foundDefault = false;
    for (var index = 0; index < _addresses.length; index++) {
      final address = _addresses[index];
      if (address.isDefault && !foundDefault) {
        foundDefault = true;
      } else if (address.isDefault) {
        _addresses[index] = address.copyWith(isDefault: false);
      }
    }
    if (!foundDefault) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
  }

  Future<void> _persist() async {
    await LocalStore.writeJson(
      _storageKey,
      _addresses.map((address) => address.toJson()).toList(),
    );
  }
}
