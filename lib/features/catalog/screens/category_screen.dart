import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../home/providers/food_preference_provider.dart';
import '../models/catalog_sort.dart';
import '../models/category.dart';
import '../providers/catalog_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/sort_sheet.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final ProductCategory category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CatalogSort _sort = CatalogSort.newest;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final preference = context.watch<FoodPreferenceProvider>().preference;
    final products = catalog.productsFor(
      preference: preference,
      categoryId: widget.category.id,
      sort: _sort,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            onPressed: () async {
              final selected = await showSortSheet(context, _sort);
              if (selected != null) setState(() => _sort = selected);
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No products here',
              message:
                  'Products matching your dietary preference will appear here.',
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
