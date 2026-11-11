import 'package:flutter_test/flutter_test.dart';
import 'package:tatito_customer/features/checkout/models/coupon.dart';
import 'package:tatito_customer/features/checkout/services/checkout_service.dart';

void main() {
  group('CheckoutService coupons', () {
    test('applies WELCOME10 above its minimum order', () {
      final result = CheckoutService.applyCoupon('welcome10', 250);

      expect(result.isValid, isTrue);
      expect(result.coupon?.code, 'WELCOME10');

      final totals = CheckoutService.totals(
        itemsTotal: 250,
        deliveryFee: 0,
        coupon: result.coupon,
      );
      expect(totals.discount, 25);
      expect(totals.total, 225);
    });

    test('caps percentage discounts', () {
      final result = CheckoutService.applyCoupon('WELCOME10', 5000);
      final totals = CheckoutService.totals(
        itemsTotal: 5000,
        deliveryFee: 29,
        coupon: result.coupon,
      );

      expect(totals.discount, 100);
      expect(totals.total, 4929);
    });

    test('rejects coupons below the minimum order', () {
      final result = CheckoutService.applyCoupon('FLAT50', 400);

      expect(result.isValid, isFalse);
      expect(result.error, contains('minimum'));
    });

    test('rejects unknown coupons', () {
      final result = CheckoutService.applyCoupon('NOPE', 1000);

      expect(result.isValid, isFalse);
      expect(result.error, contains('not valid'));
    });

    test('flat coupons never exceed the item total', () {
      const coupon = Coupon(
        code: 'TEST',
        description: 'Test coupon',
        type: CouponType.flat,
        value: 50,
        minimumOrder: 0,
      );
      final totals = CheckoutService.totals(
        itemsTotal: 40,
        deliveryFee: 0,
        coupon: coupon,
      );

      expect(totals.discount, 40);
      expect(totals.total, 0);
    });
  });
}
