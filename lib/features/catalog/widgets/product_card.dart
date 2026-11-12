import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/food_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TatitoColors.borderSubtle, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FoodBadge(foodType: product.foodType),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product.hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                TatitoColors.brandGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercentage}% OFF',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: TatitoColors.brandGold,
                            ),
                          ),
                        )
                      else if (product.isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TatitoColors.brandGreenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ORGANIC',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: TatitoColors.brandGreen,
                            ),
                          ),
                        ),
                      _WishlistHeart(product: product),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: product.gallery.isNotEmpty
                      ? Image.network(
                          product.gallery.first,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: TatitoColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TatitoColors.brandBlack,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: TatitoColors.brandGold,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TatitoColors.textBody,
                    ),
                  ),
                  Text(
                    ' (${product.reviewsCount})',
                    style: const TextStyle(
                      fontSize: 10,
                      color: TatitoColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMoney(product.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: TatitoColors.brandBlack,
                        ),
                      ),
                      if (product.hasDiscount)
                        Text(
                          formatMoney(product.mrp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: TatitoColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  _buildAddButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: TatitoColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.shopping_basket_outlined,
        color: TatitoColors.brandGreen,
        size: 34,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.getQuantity(product.id);

        if (!product.isAvailable) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: TatitoColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'OUT OF STOCK',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: TatitoColors.textMuted,
              ),
            ),
          );
        }

        if (qty == 0) {
          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              cart.addItem(product);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: TatitoColors.brandGreenLight,
                border: Border.all(color: TatitoColors.brandGreen, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TatitoColors.brandGreen,
                ),
              ),
            ),
          );
        }

        return Container(
          height: 30,
          decoration: BoxDecoration(
            color: TatitoColors.brandGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 24, minHeight: 28),
                icon: const Icon(Icons.remove, size: 15, color: Colors.white),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  cart.removeOne(product);
                },
              ),
              Text(
                '$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 24, minHeight: 28),
                icon: const Icon(Icons.add, size: 15, color: Colors.white),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  cart.addItem(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<WishlistProvider>().contains(product.id);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        if (!context.read<AuthProvider>().isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in to save items to your wishlist.')),
          );
          return;
        }
        await context.read<WishlistProvider>().toggle(product.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          saved ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: saved ? TatitoColors.dangerRed : TatitoColors.textMuted,
        ),
      ),
    );
  }
}
