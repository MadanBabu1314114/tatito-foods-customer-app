class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isApproved = false,
  });

  final String id;
  final int productId;
  final String userId;
  final int rating;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isApproved;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
    };
  }
}
