import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tatito_colors.dart';
import 'food_badge.dart';

enum FoodPreference { all, veg, nonVeg }

class VegTogglePill extends StatelessWidget {
  final FoodPreference currentPreference;
  final ValueChanged<FoodPreference> onChanged;

  const VegTogglePill({
    super.key,
    required this.currentPreference,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TatitoColors.divider,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TatitoColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            label: 'All',
            isSelected: currentPreference == FoodPreference.all,
            onTap: () => _select(FoodPreference.all),
          ),
          _buildItem(
            label: 'Veg',
            foodType: FoodType.veg,
            isSelected: currentPreference == FoodPreference.veg,
            onTap: () => _select(FoodPreference.veg),
          ),
          _buildItem(
            label: 'Non-Veg',
            foodType: FoodType.nonVeg,
            isSelected: currentPreference == FoodPreference.nonVeg,
            onTap: () => _select(FoodPreference.nonVeg),
          ),
        ],
      ),
    );
  }

  void _select(FoodPreference preference) {
    if (currentPreference != preference) {
      HapticFeedback.selectionClick();
      onChanged(preference);
    }
  }

  Widget _buildItem({
    required String label,
    FoodType? foodType,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (foodType != null) ...[
              FoodBadge(foodType: foodType, size: 12),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? TatitoColors.brandBlack : TatitoColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
