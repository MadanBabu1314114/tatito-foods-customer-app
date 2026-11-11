import '../../../core/widgets/food_badge.dart';

/// Catalog product used across the local/mock customer experience.
class Product {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String description;
  final FoodType? foodType;
  final double price;
  final double mrp;
  final String unit;
  final int stock;
  final String? image;
  final List<String> images;
  final bool isOrganic;
  final bool isActive;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    this.foodType,
    required this.price,
    required this.mrp,
    required this.unit,
    required this.stock,
    this.image,
    this.images = const [],
    this.isOrganic = false,
    this.isActive = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  bool get inStock => isActive && stock > 0;
  bool get isAvailable => inStock;
  bool get hasDiscount => mrp > price;
  int get discountPercentage =>
      hasDiscount ? (((mrp - price) / mrp) * 100).round() : 0;

  /// All product photos, falling back to the primary image when needed.
  List<String> get gallery {
    final photos = <String>[
      if (image != null && image!.isNotEmpty) image!,
      ...images.where((photo) => photo.isNotEmpty),
    ];
    return photos.toSet().toList();
  }

  Product copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? slug,
    String? description,
    FoodType? foodType,
    bool clearFoodType = false,
    double? price,
    double? mrp,
    String? unit,
    int? stock,
    String? image,
    List<String>? images,
    bool? isOrganic,
    bool? isActive,
    double? rating,
    int? reviewsCount,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      foodType: clearFoodType ? null : (foodType ?? this.foodType),
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      images: images ?? this.images,
      isOrganic: isOrganic ?? this.isOrganic,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    FoodType? foodType;
    final foodTypeValue = json['food_type'] as String?;
    if (foodTypeValue == 'veg') {
      foodType = FoodType.veg;
    } else if (foodTypeValue == 'non_veg') {
      foodType = FoodType.nonVeg;
    }

    final images = (json['images'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();

    return Product(
      id: json['id'] as int,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      foodType: foodType,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      image: json['image'] as String?,
      images: images,
      isOrganic: json['is_organic'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'food_type': foodType == FoodType.veg
          ? 'veg'
          : (foodType == FoodType.nonVeg ? 'non_veg' : null),
      'price': price,
      'mrp': mrp,
      'unit': unit,
      'stock': stock,
      'image': image,
      'images': images,
      'is_organic': isOrganic,
      'is_active': isActive,
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }
}
