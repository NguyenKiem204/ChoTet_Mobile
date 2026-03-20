import 'shopping_item.dart';
import 'user_short.dart';

class ShoppingList {
  final String id;
  final String name;
  final double budget;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? imageUrl;
  final String? status;
  final String? userId; // Owner ID
  final List<UserShort> sharedUsers;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.budget,
    required this.items,
    required this.createdAt,
    this.scheduledDate,
    this.imageUrl,
    this.status,
    this.userId,
    this.sharedUsers = const [],
  });

  factory ShoppingList.empty() {
    return ShoppingList(
      id: '',
      name: '',
      budget: 0,
      items: [],
      createdAt: DateTime.now(),
    );
  }

  DateTime get date => scheduledDate ?? createdAt;

  double get totalEstimated => items.fold(0, (sum, item) => sum + item.total);
  double get totalActual => items.where((i) => i.isPurchased).fold(0, (sum, item) => sum + item.total);
  
  int get purchasedCount => items.where((i) => i.isPurchased).length;
  int get totalCount => items.length;
  
  double get progress => totalCount == 0 ? 0 : purchasedCount / totalCount;
  bool get isOverBudget => totalActual > budget;
  
  bool isOwner(String? currentUserId) => userId == currentUserId;
  bool isSharedWith(String? currentUserId) => sharedUsers.any((u) => u.id.toString() == currentUserId);

  ShoppingList copyWith({
    String? name,
    double? budget,
    List<ShoppingItem>? items,
    DateTime? scheduledDate,
    String? imageUrl,
    String? status,
    List<UserShort>? sharedUsers,
  }) {
    return ShoppingList(
      id: id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      items: items ?? this.items,
      createdAt: createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      userId: userId,
      sharedUsers: sharedUsers ?? this.sharedUsers,
    );
  }
}
