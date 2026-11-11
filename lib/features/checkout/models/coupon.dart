import 'dart:math' as math;

enum CouponType { percent, flat }

class Coupon {
  const Coupon({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.minimumOrder,
    this.maxDiscount,
  });

  final String code;
  final String description;
  final CouponType type;
  final double value;
  final double minimumOrder;
  final double? maxDiscount;

  double discountFor(double subtotal) {
    if (subtotal < minimumOrder) return 0;
    if (type == CouponType.flat) return value.clamp(0, subtotal).toDouble();
    final percentDiscount = subtotal * value / 100;
    final capped = maxDiscount == null
        ? percentDiscount
        : math.min(percentDiscount, maxDiscount!);
    return capped.clamp(0, subtotal).toDouble();
  }
}
