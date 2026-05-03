class Product {
  final int? id;
  final String title;
  final String category;
  final String? imageUrl;
  final double uvpPrice;
  final double purchasePrice1;
  final double purchasePrice5;
  final double purchasePrice10;
  final bool isActive;
  final int sortOrder;

  const Product({
    this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.uvpPrice,
    required this.purchasePrice1,
    required this.purchasePrice5,
    required this.purchasePrice10,
    this.isActive = true,
    this.sortOrder = 0,
  });

  double purchasePriceForTier(int tier) {
    switch (tier) {
      case 5:
        return purchasePrice5;
      case 10:
        return purchasePrice10;
      default:
        return purchasePrice1;
    }
  }

  String tierLabel(int tier) {
    switch (tier) {
      case 5:
        return '5 шт';
      case 10:
        return '10 шт';
      default:
        return '1 шт';
    }
  }

  Product copyWith({
    int? id,
    String? title,
    String? category,
    String? imageUrl,
    double? uvpPrice,
    double? purchasePrice1,
    double? purchasePrice5,
    double? purchasePrice10,
    bool? isActive,
    int? sortOrder,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      uvpPrice: uvpPrice ?? this.uvpPrice,
      purchasePrice1: purchasePrice1 ?? this.purchasePrice1,
      purchasePrice5: purchasePrice5 ?? this.purchasePrice5,
      purchasePrice10: purchasePrice10 ?? this.purchasePrice10,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'image_url': imageUrl,
      'uvp_price': uvpPrice,
      'purchase_price_1': purchasePrice1,
      'purchase_price_5': purchasePrice5,
      'purchase_price_10': purchasePrice10,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      imageUrl: map['image_url'] as String?,
      uvpPrice: (map['uvp_price'] as num).toDouble(),
      purchasePrice1: (map['purchase_price_1'] as num).toDouble(),
      purchasePrice5: (map['purchase_price_5'] as num).toDouble(),
      purchasePrice10: (map['purchase_price_10'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }
}
