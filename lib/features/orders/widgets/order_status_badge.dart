import 'package:flutter/material.dart';

import '../../../core/theme/tatito_colors.dart';
import '../models/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color get _color {
    switch (status) {
      case OrderStatus.delivered:
        return TatitoColors.brandGreen;
      case OrderStatus.cancelled:
        return TatitoColors.dangerRed;
      case OrderStatus.outForDelivery:
        return const Color(0xFF2563EB);
      case OrderStatus.packed:
      case OrderStatus.confirmed:
        return TatitoColors.warningOrange;
      case OrderStatus.placed:
        return TatitoColors.textBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}
