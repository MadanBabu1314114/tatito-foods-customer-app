import 'package:flutter/material.dart';
import '../theme/tatito_colors.dart';

enum FoodType { veg, nonVeg }

class FoodBadge extends StatelessWidget {
  final FoodType? foodType;
  final double size;

  const FoodBadge({
    super.key,
    required this.foodType,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (foodType == null) {
      return const SizedBox.shrink();
    }

    final isVeg = foodType == FoodType.veg;
    final color = isVeg ? TatitoColors.vegGreen : TatitoColors.nonVegRed;
    final dotSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
