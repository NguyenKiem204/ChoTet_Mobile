class ShoppingListDto {
  final int? id;
  final int? userId;
  final String name;
  final double? budget;
  final double? totalEstimated;
  final double? totalActual;
  final DateTime? scheduledDate;
  final String? imageUrl;
  final String? status;
  final DateTime? createdAt;
  final List<ShoppingItemDto> items;
  final List<UserShortDto> sharedUsers;

  ShoppingListDto({
    this.id,
    this.userId,
    required this.name,
    this.budget,
    this.totalEstimated,
    this.totalActual,
    this.scheduledDate,
    this.imageUrl,
    this.status,
    this.createdAt,
    this.items = const [],
    this.sharedUsers = const [],
  });

  factory ShoppingListDto.fromJson(Map<String, dynamic> json) {
    return ShoppingListDto(
      id: json['id'],
      userId: json['userId'],
      name: json['name'] ?? '',
      budget: (json['budget'] as num?)?.toDouble(),
      totalEstimated: (json['totalEstimated'] as num?)?.toDouble(),
      totalActual: (json['totalActual'] as num?)?.toDouble(),
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      imageUrl: json['imageUrl'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ShoppingItemDto.fromJson(i)).toList()
          : [],
      sharedUsers: json['sharedUsers'] != null
          ? (json['sharedUsers'] as List).map((i) => UserShortDto.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'budget': budget,
    'scheduledDate': scheduledDate?.toIso8601String().split('T')[0], // YYYY-MM-DD
    'imageUrl': imageUrl,
    'status': status,
    'sharedUsers': sharedUsers.map((u) => u.toJson()).toList(),
  };
}

class UserShortDto {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? imageUrl;
  final String? nickname;

  UserShortDto({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.imageUrl,
    this.nickname,
  });

  factory UserShortDto.fromJson(Map<String, dynamic> json) {
    return UserShortDto(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'],
      imageUrl: json['imageUrl'],
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'avatarUrl': avatarUrl,
    'imageUrl': imageUrl,
    'nickname': nickname,
  };
}

class ShoppingItemDto {
  final int? id;
  final int? listId;
  final String name;
  final double quantity;
  final String unit;
  final double? estimatedPrice;
  final double? actualPrice;
  final bool isPurchased;
  final bool isExtra;
  final String? imageUrl;
  final String? category;
  final DateTime? scheduledDate;
  final String? note;
  final UserShortDto? purchasedBy;

  ShoppingItemDto({
    this.id,
    this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.estimatedPrice,
    this.actualPrice,
    this.isPurchased = false,
    this.isExtra = false,
    this.imageUrl,
    this.category,
    this.scheduledDate,
    this.note,
    this.purchasedBy,
  });

  factory ShoppingItemDto.fromJson(Map<String, dynamic> json) {
    return ShoppingItemDto(
      id: json['id'],
      listId: json['listId'],
      name: json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble(),
      isPurchased: json['isPurchased'] ?? false,
      isExtra: json['isExtra'] ?? false,
      imageUrl: json['imageUrl'],
      category: json['category'],
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      note: json['note'],
      purchasedBy: json['purchasedBy'] != null ? UserShortDto.fromJson(json['purchasedBy']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'listId': listId,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'estimatedPrice': estimatedPrice,
    'actualPrice': actualPrice,
    'isPurchased': isPurchased,
    'isExtra': isExtra,
    'imageUrl': imageUrl,
    'category': category,
    'scheduledDate': scheduledDate?.toIso8601String().split('T')[0],
    'note': note,
    'purchasedBy': purchasedBy?.toJson(),
  };
}

class ScanResponseDto {
  final List<ScannedItemUpdateDto> updatedItems;
  final List<ScannedItemUpdateDto> extraItems;
  final double totalNewExpenses;

  ScanResponseDto({
    required this.updatedItems,
    required this.extraItems,
    required this.totalNewExpenses,
  });

  factory ScanResponseDto.fromJson(Map<String, dynamic> json) {
    return ScanResponseDto(
      updatedItems: json['updatedItems'] != null
          ? (json['updatedItems'] as List).map((i) => ScannedItemUpdateDto.fromJson(i)).toList()
          : [],
      extraItems: json['extraItems'] != null
          ? (json['extraItems'] as List).map((i) => ScannedItemUpdateDto.fromJson(i)).toList()
          : [],
      totalNewExpenses: (json['totalNewExpenses'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ScannedItemUpdateDto {
  final int? id;
  final String name;
  final double price;
  final double quantity;
  final bool isExtra;
  final String status;
  final String? listName;

  ScannedItemUpdateDto({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isExtra,
    required this.status,
    this.listName,
  });

  factory ScannedItemUpdateDto.fromJson(Map<String, dynamic> json) {
    return ScannedItemUpdateDto(
      id: json['id'],
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      isExtra: json['isExtra'] ?? false,
      status: json['status'] ?? '',
      listName: json['listName'],
    );
  }
}
