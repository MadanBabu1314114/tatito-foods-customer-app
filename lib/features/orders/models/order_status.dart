enum OrderStatus {
  placed,
  confirmed,
  packed,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusText on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canCancel =>
      this == OrderStatus.placed || this == OrderStatus.confirmed;
  bool get isDelivered => this == OrderStatus.delivered;

  static OrderStatus fromStorage(String value) {
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'packed':
        return OrderStatus.packed;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  String get storageValue {
    switch (this) {
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      default:
        return name;
    }
  }
}

enum OrderPaymentMethod { cod, online }

extension OrderPaymentMethodText on OrderPaymentMethod {
  String get label => this == OrderPaymentMethod.cod ? 'Cash on Delivery' : 'Pay Online';

  static OrderPaymentMethod fromStorage(String value) {
    return value == 'online' ? OrderPaymentMethod.online : OrderPaymentMethod.cod;
  }
}

enum OrderPaymentStatus { pending, paid, failed, refunded }

extension OrderPaymentStatusText on OrderPaymentStatus {
  String get label {
    switch (this) {
      case OrderPaymentStatus.pending:
        return 'Payment pending';
      case OrderPaymentStatus.paid:
        return 'Paid';
      case OrderPaymentStatus.failed:
        return 'Payment failed';
      case OrderPaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static OrderPaymentStatus fromStorage(String value) {
    switch (value) {
      case 'paid':
        return OrderPaymentStatus.paid;
      case 'failed':
        return OrderPaymentStatus.failed;
      case 'refunded':
        return OrderPaymentStatus.refunded;
      default:
        return OrderPaymentStatus.pending;
    }
  }
}
