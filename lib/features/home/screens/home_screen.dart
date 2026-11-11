import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/widgets/tatito_cart_bar.dart';
import '../../../core/widgets/veg_toggle.dart';
import '../../account/screens/account_screen.dart';
import '../../addresses/models/address.dart';
import '../../addresses/providers/address_provider.dart';
import '../../addresses/screens/address_list_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../catalog/models/banner_item.dart';
import '../../catalog/models/catalog_sort.dart';
import '../../catalog/models/category.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../catalog/screens/category_screen.dart';
import '../../catalog/screens/product_detail_screen.dart';
import '../../catalog/screens/search_screen.dart';
import '../../catalog/widgets/product_card.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../providers/food_preference_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preference = context.watch<FoodPreferenceProvider>().preference;
    final catalog = context.watch<CatalogProvider>();
    final address = context.watch<AddressProvider>().defaultAddress;
    final products = catalog.productsFor(
      preference: preference,
      sort: CatalogSort.popularity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tatito ',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: TatitoColors.brandBlack,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Foods',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: TatitoColors.brandGreen,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddressListScreen(),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: TatitoColors.brandGreen,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    address == null
                        ? 'Deliver to: Add address'
                        : 'Deliver to: ${address.label.label} (${address.pincode})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: TatitoColors.textBody,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: TatitoColors.textBody,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'My account',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: TatitoColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: TatitoColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: TatitoColors.borderSubtle,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: TatitoColors.brandGreen,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Search vegetables, fruits, groceries...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TatitoColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dietary filter:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TatitoColors.textMuted,
                            ),
                          ),
                          VegTogglePill(
                            currentPreference: preference,
                            onChanged: (newPreference) {
                              context
                                  .read<FoodPreferenceProvider>()
                                  .setPreference(newPreference);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    itemCount: catalog.banners.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _BannerCard(
                      banner: catalog.banners[index],
                      index: index,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shop by category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TatitoColors.brandBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: catalog.categories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return _CategoryCircle(
                              category: catalog.categories[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _sectionTitle(preference),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TatitoColors.brandBlack,
                              ),
                            ),
                          ),
                          Text(
                            '${products.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: TatitoColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: products.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No products match this dietary filter. Try switching to All.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TatitoColors.textMuted),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.66,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              ),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 110),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TatitoCartBar(
              onViewCart: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(FoodPreference preference) {
    switch (preference) {
      case FoodPreference.veg:
        return 'Fresh veg picks 🟢';
      case FoodPreference.nonVeg:
        return 'Non-veg specialties 🔴';
      case FoodPreference.all:
        return 'Fresh harvest & essentials';
    }
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.index});

  final BannerItem banner;
  final int index;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [TatitoColors.brandGreenDark, TatitoColors.brandGreen],
      [Color(0xFF7A5C00), TatitoColors.brandGold],
      [Color(0xFF0F4C5C), Color(0xFF2A9D8F)],
    ];

    return Container(
      width: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients[index % gradients.length],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    banner.badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.local_shipping_outlined,
            size: 48,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({required this.category});

  final ProductCategory category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(category: category),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: TatitoColors.brandGreenLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: TatitoColors.brandGreen.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _iconFor(category.slug),
                color: TatitoColors.brandGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: TatitoColors.brandBlack,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String slug) {
    switch (slug) {
      case 'vegetables':
        return Icons.eco_rounded;
      case 'leafy-greens':
        return Icons.grass_rounded;
      case 'fruits':
        return Icons.local_florist_rounded;
      case 'meat-fish':
        return Icons.set_meal_rounded;
      case 'dairy-eggs':
        return Icons.breakfast_dining_rounded;
      case 'staples':
        return Icons.rice_bowl_rounded;
      case 'snacks':
        return Icons.cookie_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'masalas-oils':
        return Icons.local_fire_department_rounded;
      case 'pet-food':
        return Icons.pets_rounded;
      case 'household':
        return Icons.cleaning_services_rounded;
      case 'organic':
        return Icons.spa_rounded;
      case 'frozen':
        return Icons.ac_unit_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }
}
