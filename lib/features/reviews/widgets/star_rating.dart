import 'package:flutter/material.dart';

import '../../../core/theme/tatito_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
  });

  final double rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = rating >= value;
        final half = !filled && rating >= value - 0.5;
        final icon = Icon(
          filled
              ? Icons.star_rounded
              : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
          size: size,
          color: TatitoColors.brandGold,
        );
        if (onChanged == null) return icon;
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => onChanged!(value),
          child: Padding(padding: const EdgeInsets.only(right: 2), child: icon),
        );
      }),
    );
  }
}
