class DeliverySlot {
  const DeliverySlot({
    required this.id,
    required this.label,
    this.isAvailable = true,
  });

  final String id;
  final String label;
  final bool isAvailable;
}
