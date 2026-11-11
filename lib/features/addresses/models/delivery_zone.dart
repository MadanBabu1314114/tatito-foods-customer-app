/// Local delivery-area quote. Real pincode data will come from the API later.
class DeliveryZone {
  const DeliveryZone({
    required this.pincode,
    required this.deliveryFee,
    required this.minimumOrder,
    this.isActive = true,
  });

  final String pincode;
  final double deliveryFee;
  final double minimumOrder;
  final bool isActive;

  bool get isServiceable => isActive;
}
