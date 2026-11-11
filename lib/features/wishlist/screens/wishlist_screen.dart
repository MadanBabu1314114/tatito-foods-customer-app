import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/sign_in_screen.dart';
import '../../catalog/models/product.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../catalog/screens/product_detail_screen.dart';
import '../../catalog/widgets/product_card.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final catalog = context.watch<CatalogProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: AppEmptyState(
          icon: Icons.favorite_border,
          title: 'Sign in to see your wishlist',
          message:
              'Save your favourite vegetables, fruits and essentials for later.',
          action: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            ),
            child: const Text('Sign in'),
          ),
        ),
      );
    }

    final products = wishlist.productIds
        .map(catalog.byId)
        .whereType<Product>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Wishlist (${products.length})')),
      body: products.isEmpty
          ? const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              message:
                  'Tap the heart on any product to save it here for your next order.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.66,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
