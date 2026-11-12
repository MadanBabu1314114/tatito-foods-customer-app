enum AddressLabel { home, work, other }

extension AddressLabelText on AddressLabel {
  String get label {
    switch (this) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.other:
        return 'Other';
    }
  }

  static AddressLabel fromStorage(String value) {
    switch (value) {
      case 'work':
        return AddressLabel.work;
      case 'other':
        return AddressLabel.other;
      default:
        return AddressLabel.home;
    }
  }
}

/// Reads an id that may be stored as an int (API / current format) or as a
/// numeric string. Returns null for legacy non-numeric ids such as
/// 'address-demo-home', so the caller can assign a fresh id.
int? _parseId(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  /// Server id once the API exists. Locally created addresses use a negative
  /// temporary id until they are saved to the server. 0 means "not assigned".
  final int id;
  final AddressLabel label;

  /// Receiver name and 10-digit Indian mobile number (`^[6-9]\d{9}$`).
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  String get singleLine {
    final parts = [line1, line2, city, state, pincode]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');
    return parts;
  }

  /// True when the fields the API requires for delivery are present.
  bool get hasContact => name.trim().isNotEmpty && phone.trim().isNotEmpty;

  Address copyWith({
    int? id,
    AddressLabel? label,
    String? name,
    String? phone,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _parseId(json['id']) ?? 0,
      label: AddressLabelText.fromStorage(json['label'] as String? ?? 'home'),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label.name,
      'name': name,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
