import '../models/address.dart';
import '../models/delivery_zone.dart';

/// Mock pincode serviceability and seeded address data.
class MockAddressRepository {
  const MockAddressRepository();

  static const List<DeliveryZone> zones = [
    DeliveryZone(pincode: '500081', deliveryFee: 0, minimumOrder: 199),
    DeliveryZone(pincode: '500033', deliveryFee: 29, minimumOrder: 299),
    DeliveryZone(pincode: '500001', deliveryFee: 19, minimumOrder: 149),
    DeliveryZone(pincode: '500034', deliveryFee: 39, minimumOrder: 349),
  ];

  DeliveryZone? zoneFor(String pincode) {
    for (final zone in zones) {
      if (zone.pincode == pincode) return zone;
    }
    return null;
  }

  List<Address> seededAddresses() {
    return const [
      Address(
        id: 1,
        label: AddressLabel.home,
        name: 'Demo Customer',
        phone: '9876543210',
        line1: 'Flat 402, Green Meadows',
        line2: 'Madhapur',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500081',
        isDefault: true,
      ),
    ];
  }
}
