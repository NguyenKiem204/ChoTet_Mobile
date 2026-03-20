class PriceBookDto {
  final int? id;
  final String itemName;
  final String storeName;
  final String unit;
  final double price;
  final String? imageUrl;
  final int? sourceListId;
  final DateTime? observedAt;

  PriceBookDto({
    this.id,
    required this.itemName,
    required this.storeName,
    required this.unit,
    required this.price,
    this.imageUrl,
    this.sourceListId,
    this.observedAt,
  });

  factory PriceBookDto.fromJson(Map<String, dynamic> json) {
    return PriceBookDto(
      id: json['id'],
      itemName: json['itemName'] ?? '',
      storeName: json['storeName'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      sourceListId: json['sourceListId'],
      observedAt: json['observedAt'] != null 
          ? DateTime.parse(json['observedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemName': itemName,
    'storeName': storeName,
    'unit': unit,
    'price': price,
    'imageUrl': imageUrl,
    'sourceListId': sourceListId,
    'observedAt': observedAt?.toIso8601String(),
  };
}
