import '../models/review.dart';

class MockReviewRepository {
  const MockReviewRepository();

  List<Review> seededReviews() {
    final now = DateTime.now();
    return [
      Review(
        id: 'review-seed-1',
        productId: 1,
        userId: 'customer-seed-1',
        rating: 5,
        title: 'Very fresh',
        body: 'Tomatoes arrived firm and fresh. Will order again.',
        createdAt: now.subtract(const Duration(days: 2)),
        isApproved: true,
      ),
      Review(
        id: 'review-seed-2',
        productId: 1,
        userId: 'customer-seed-2',
        rating: 4,
        title: 'Good quality',
        body: 'Nice colour and taste, one tomato was slightly soft.',
        createdAt: now.subtract(const Duration(days: 6)),
        isApproved: true,
      ),
      Review(
        id: 'review-seed-3',
        productId: 3,
        userId: 'customer-seed-3',
        rating: 5,
        title: 'Clean and well packed',
        body: 'Chicken was cleaned properly and sealed well.',
        createdAt: now.subtract(const Duration(days: 4)),
        isApproved: true,
      ),
      Review(
        id: 'review-seed-4',
        productId: 5,
        userId: 'customer-seed-4',
        rating: 5,
        title: 'Pure honey',
        body: 'Rich flavour and the jar was sealed. Worth the price.',
        createdAt: now.subtract(const Duration(days: 8)),
        isApproved: true,
      ),
      Review(
        id: 'review-seed-5',
        productId: 15,
        userId: 'customer-seed-5',
        rating: 4,
        title: 'Fresh greens',
        body: 'Spinach was clean and tender. Cooked it the same day.',
        createdAt: now.subtract(const Duration(days: 1)),
        isApproved: true,
      ),
    ];
  }
}
