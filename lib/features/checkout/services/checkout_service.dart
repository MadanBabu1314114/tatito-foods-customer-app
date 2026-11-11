import 'dart:math' as math;

import '../models/coupon.dart';
import '../models/delivery_slot.dart';

class CouponResult {
  const CouponResult._({this.coupon, this.error});

  const CouponResult.success(Coupon coupon) : this._(coupon: coupon);
  const CouponResult.failure(String error) : this._(error: error);

  final Coupon? coupon;
  final String? error;

  bool get isValid => coupon != null;
}

class CheckoutTotals {
  const CheckoutTotals({
    required this.itemsTotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  final double itemsTotal;
  final double discount;
  final double deliveryFee;
  final double total;
}

/// Pure local checkout rules. No payment gateway or API is called.
class CheckoutService {
  const CheckoutService._();

  static const List<Coupon> coupons = [
    Coupon(
      code: 'WELCOME10',
      description: '10% off up to ₹100 on orders above ₹199',
      type: CouponType.percent,
      value: 10,
      minimumOrder: 199,
      maxDiscount: 100,
    ),
    Coupon(
      code: 'FLAT50',
      description: 'Flat ₹50 off on orders above ₹499',
      type: CouponType.flat,
      value: 50,
      minimumOrder: 499,
    ),
    Coupon(
      code: 'ORGANIC15',
      description: '15% off up to ₹150 on orders above ₹299',
      type: CouponType.percent,
      value: 15,
      minimumOrder: 299,
      maxDiscount: 150,
    ),
  ];

  static const List<DeliverySlot> slots = [
    DeliverySlot(id: 'slot-1', label: '9:00 AM - 11:00 AM'),
    DeliverySlot(id: 'slot-2', label: '11:00 AM - 1:00 PM'),
    DeliverySlot(id: 'slot-3', label: '4:00 PM - 6:00 PM'),
    DeliverySlot(id: 'slot-4', label: '6:00 PM - 8:00 PM'),
    DeliverySlot(id: 'slot-5', label: '8:00 PM - 10:00 PM'),
  ];

  static CouponResult applyCoupon(String code, double subtotal) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const CouponResult.failure('Enter a coupon code.');
    }
    for (final coupon in coupons) {
      if (coupon.code != normalized) continue;
      if (subtotal < coupon.minimumOrder) {
        return CouponResult.failure(
          '${coupon.code} needs a minimum item total of ₹${coupon.minimumOrder.toStringAsFixed(0)}.',
        );
      }
      return CouponResult.success(coupon);
    }
    return const CouponResult.failure('This coupon is not valid.');
  }

  static CheckoutTotals totals({
    required double itemsTotal,
    required double deliveryFee,
    Coupon? coupon,
  }) {
    final discount = coupon?.discountFor(itemsTotal) ?? 0;
    final total = math.max(0, itemsTotal + deliveryFee - discount).toDouble();
    return CheckoutTotals(
      itemsTotal: itemsTotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
    );
  }
}
