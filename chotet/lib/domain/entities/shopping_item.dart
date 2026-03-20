import 'user_short.dart';

class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double estimatedPrice;
  final double? actualPrice;
  final bool isPurchased;
  final bool isExtra;
  final String category;
  final String? imageUrl;
  final DateTime? scheduledDate;
  final UserShort? purchasedBy;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.actualPrice,
    this.isPurchased = false,
    this.isExtra = false,
    required this.category,
    this.imageUrl,
    this.scheduledDate,
    this.purchasedBy,
  });

  double get price => actualPrice ?? estimatedPrice;
  double get total => price * quantity;

  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    double? actualPrice,
    bool? isPurchased,
    bool? isExtra,
    String? category,
    String? imageUrl,
    DateTime? scheduledDate,
    UserShort? purchasedBy,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      isPurchased: isPurchased ?? this.isPurchased,
      isExtra: isExtra ?? this.isExtra,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      purchasedBy: purchasedBy ?? this.purchasedBy,
    );
  }
}
