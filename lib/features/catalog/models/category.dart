class ProductCategory {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? parentId;
  final int sortOrder;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String?,
      parentId: json['parent_id'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
