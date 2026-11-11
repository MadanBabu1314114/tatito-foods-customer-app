/// Local catalog sorting options. Sorting happens entirely in memory.
enum CatalogSort {
  newest,
  priceLowHigh,
  priceHighLow,
  nameAsc,
  rating,
  popularity,
}

extension CatalogSortLabel on CatalogSort {
  String get label {
    switch (this) {
      case CatalogSort.newest:
        return 'Newest first';
      case CatalogSort.priceLowHigh:
        return 'Price: low to high';
      case CatalogSort.priceHighLow:
        return 'Price: high to low';
      case CatalogSort.nameAsc:
        return 'Name: A to Z';
      case CatalogSort.rating:
        return 'Top rated';
      case CatalogSort.popularity:
        return 'Most popular';
    }
  }
}
