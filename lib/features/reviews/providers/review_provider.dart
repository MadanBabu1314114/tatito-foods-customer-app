import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../../orders/providers/orders_provider.dart';
import '../data/mock_review_repository.dart';
import '../models/review.dart';

/// Review moderation is simulated: submitted reviews stay pending until an
/// admin API approves them. Seeded approved reviews are shown immediately.
class ReviewProvider extends ChangeNotifier {
  ReviewProvider({MockReviewRepository? repository})
      : _repository = repository ?? const MockReviewRepository() {
    _load();
  }

  static const String _storageKey = 'tatito_reviews_v1';

  final MockReviewRepository _repository;
  final List<Review> _reviews = [];

  List<Review> approvedFor(int productId) {
    return _reviews
        .where((review) => review.productId == productId && review.isApproved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Review> pendingForUser(String userId) {
    return _reviews
        .where((review) => review.userId == userId && !review.isApproved)
        .toList();
  }

  double? averageFor(int productId) {
    final reviews = approvedFor(productId);
    if (reviews.isEmpty) return null;
    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  bool hasReviewed({required int productId, required String? userId}) {
    if (userId == null) return false;
    return _reviews.any(
      (review) => review.productId == productId && review.userId == userId,
    );
  }

  bool canReview({
    required int productId,
    required String? userId,
    required OrdersProvider orders,
  }) {
    if (userId == null) return false;
    if (hasReviewed(productId: productId, userId: userId)) return false;
    return orders.hasDeliveredProduct(userId: userId, productId: productId);
  }

  Future<void> submit({
    required int productId,
    required String userId,
    required int rating,
    required String title,
    required String body,
  }) async {
    _reviews.insert(
      0,
      Review(
        id: 'review-${DateTime.now().microsecondsSinceEpoch}',
        productId: productId,
        userId: userId,
        rating: rating,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await LocalStore.readJson(_storageKey);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _reviews.add(
            Review.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    } else {
      _reviews.addAll(_repository.seededReviews());
      await _persist();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await LocalStore.writeJson(
      _storageKey,
      _reviews.map((review) => review.toJson()).toList(),
    );
  }
}
