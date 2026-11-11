import '../../../core/widgets/food_badge.dart';
import '../../../core/widgets/veg_toggle.dart';
import '../models/catalog_sort.dart';
import '../models/product.dart';

/// Applies the persisted All / Veg / Non-Veg preference.
/// Household products (null food type) remain visible in every mode.
bool matchesFoodPreference(Product product, FoodPreference preference) {
  switch (preference) {
    case FoodPreference.all:
      return true;
    case FoodPreference.veg:
      return product.foodType == FoodType.veg || product.foodType == null;
    case FoodPreference.nonVeg:
      return product.foodType == FoodType.nonVeg || product.foodType == null;
  }
}

/// Local filtering and sorting used by home, category and search screens.
List<Product> filterAndSortProducts(
  Iterable<Product> products, {
  required FoodPreference preference,
  String query = '',
  CatalogSort sort = CatalogSort.newest,
}) {
  final search = query.trim().toLowerCase();
  final result = products.where((product) {
    if (!product.isAvailable) return false;
    if (!matchesFoodPreference(product, preference)) return false;
    if (search.isEmpty) return true;
    return product.name.toLowerCase().contains(search) ||
        product.description.toLowerCase().contains(search) ||
        product.slug.toLowerCase().contains(search);
  }).toList();

  switch (sort) {
    case CatalogSort.newest:
      result.sort((a, b) => b.id.compareTo(a.id));
      break;
    case CatalogSort.priceLowHigh:
      result.sort((a, b) => a.price.compareTo(b.price));
      break;
    case CatalogSort.priceHighLow:
      result.sort((a, b) => b.price.compareTo(a.price));
      break;
    case CatalogSort.nameAsc:
      result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case CatalogSort.rating:
      result.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case CatalogSort.popularity:
      result.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
      break;
  }
  return result;
}
