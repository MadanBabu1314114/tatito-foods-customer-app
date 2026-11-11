import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/food_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../reviews/models/review.dart';
import '../../reviews/providers/review_provider.dart';
import '../../reviews/screens/review_form_screen.dart';
import '../../reviews/widgets/star_rating.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../models/product.dart';
import '../providers/catalog_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final current = catalog.byId(product.id) ?? product;
    final reviews = context.watch<ReviewProvider>().approvedFor(current.id);
    final average = context.watch<ReviewProvider>().averageFor(current.id);
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final reviewProvider = context.watch<ReviewProvider>();

    final canReview = reviewProvider.canReview(
      productId: current.id,
      userId: auth.currentUser?.id,
      orders: orders,
    );
    final alreadyReviewed = reviewProvider.hasReviewed(
      productId: current.id,
      userId: auth.currentUser?.id,
    );
    final displayRating = average ?? current.rating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            icon: Icon(
              wishlist.contains(current.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: wishlist.contains(current.id)
                  ? TatitoColors.dangerRed
                  : null,
            ),
            onPressed: () async {
              if (!auth.isAuthenticated) {
                _showMessage(context, 'Sign in to save items to your wishlist.');
                return;
              }
              await context.read<WishlistProvider>().toggle(current.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _ProductImage(product: current),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FoodBadge(foodType: current.foodType, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        current.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TatitoColors.brandBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  current.unit,
                  style: const TextStyle(
                    color: TatitoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StarRating(rating: displayRating, size: 19),
                    const SizedBox(width: 6),
                    Text(
                      displayRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${reviews.isEmpty ? current.reviewsCount : reviews.length} reviews)',
                      style: const TextStyle(
                        color: TatitoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(current.price),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TatitoColors.brandGreenDark,
                      ),
                    ),
                    if (current.hasDiscount) ...[
                      const SizedBox(width: 10),
                      Text(
                        formatMoney(current.mrp),
                        style: const TextStyle(
                          fontSize: 16,
                          color: TatitoColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TatitoColors.brandGold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${current.discountPercentage}% OFF',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: TatitoColors.brandGold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  current.isAvailable
                      ? 'In stock (${current.stock} available)'
                      : 'Out of stock',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: current.isAvailable
                        ? TatitoColors.brandGreen
                        : TatitoColors.dangerRed,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  current.description,
                  style: const TextStyle(
                    color: TatitoColors.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Customer reviews',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (canReview)
                      TextButton(
                        onPressed: () async {
                          final submitted = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewFormScreen(product: current),
                            ),
                          );
                          if (submitted == true && context.mounted) {
                            _showMessage(
                              context,
                              'Review submitted for approval. Thank you!',
                            );
                          }
                        },
                        child: const Text('Write a review'),
                      ),
                  ],
                ),
                if (alreadyReviewed)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Your review is awaiting store approval.',
                      style: TextStyle(
                        color: TatitoColors.warningOrange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No approved reviews yet.',
                      style: TextStyle(color: TatitoColors.textMuted),
                    ),
                  )
                else
                  ...reviews.take(5).map(_ReviewCard.new),
                if (!canReview &&
                    !alreadyReviewed &&
                    auth.isAuthenticated &&
                    !current.isAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Reviews open after a delivered order containing this product.',
                      style: TextStyle(
                        color: TatitoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(product: current),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final photo = product.gallery.isEmpty ? null : product.gallery.first;
    return Container(
      height: 240,
      width: double.infinity,
      color: TatitoColors.surfaceAlt,
      child: photo == null
          ? const Center(
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 84,
                color: TatitoColors.brandGreen,
              ),
            )
          : Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 84,
                  color: TatitoColors.brandGreen,
                ),
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.review);

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StarRating(rating: review.rating.toDouble(), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formatDateTime(review.createdAt).split(' ').first,
                  style: const TextStyle(
                    fontSize: 11,
                    color: TatitoColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              review.body,
              style: const TextStyle(
                fontSize: 13,
                color: TatitoColors.textBody,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TatitoColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            final quantity = cart.getQuantity(product.id);
            if (!product.isAvailable) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'This product is not available right now.',
                    style: TextStyle(color: TatitoColors.dangerRed),
                  ),
                ),
              );
            }
            if (quantity == 0) {
              return ElevatedButton.icon(
                onPressed: () {
                  cart.addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to basket.'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to basket'),
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Text(
                    '$quantity in basket · ${formatMoney(product.price * quantity)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => cart.removeOne(product),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => cart.addItem(product),
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
