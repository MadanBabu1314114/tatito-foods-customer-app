import '../../catalog/models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Product product;
  int quantity;

  double get total => product.price * quantity;
  double get originalTotal => product.mrp * quantity;
  double get savings => originalTotal - total;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
