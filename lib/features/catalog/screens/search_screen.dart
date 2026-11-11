import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../home/providers/food_preference_provider.dart';
import '../models/catalog_sort.dart';
import '../providers/catalog_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/sort_sheet.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  CatalogSort _sort = CatalogSort.newest;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuery(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final preference = context.watch<FoodPreferenceProvider>().preference;
    final suggestions = catalog.suggestionsFor(_query);
    final results = catalog.productsFor(
      preference: preference,
      query: _query,
      sort: _sort,
    );
    final popular = catalog.categories.take(8).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _updateQuery,
          decoration: InputDecoration(
            hintText: 'Search vegetables, fruits, groceries...',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      _updateQuery('');
                    },
                  ),
          ),
        ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_query.isNotEmpty && suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: suggestions
                    .map(
                      (suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed: () {
                          _controller.text = suggestion;
                          _controller.selection = TextSelection.collapsed(
                            offset: suggestion.length,
                          );
                          _updateQuery(suggestion);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          if (_query.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TatitoColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: popular
                        .map(
                          (category) => ActionChip(
                            label: Text(category.name),
                            onPressed: () {
                              _controller.text = category.name;
                              _updateQuery(category.name);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              _query.isEmpty
                  ? 'All products (${results.length})'
                  : '${results.length} result(s) for "$_query"',
              style: const TextStyle(
                fontSize: 13,
                color: TatitoColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No matching products.\nTry a different search or switch the dietary filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TatitoColors.textMuted),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.66,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
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
                  ),
          ),
        ],
      ),
    );
  }
}
