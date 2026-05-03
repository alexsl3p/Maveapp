class Sale {
  final int? id;
  final int productId;
  final int sellerId;
  final String productTitleSnapshot;
  final String sellerNameSnapshot;
  final double purchasePriceSnapshot;
  final double salePriceSnapshot;
  final String priceMode; // 'uvp' or 'custom'
  final int purchaseTier; // 1, 5, or 10
  final int quantity;
  final double profit;
  final double margin;
  final DateTime soldAt;
  final String monthKey; // 'YYYY-MM'
  final String? note;
  final String status; // 'active' or 'cancelled'

  const Sale({
    this.id,
    required this.productId,
    required this.sellerId,
    required this.productTitleSnapshot,
    required this.sellerNameSnapshot,
    required this.purchasePriceSnapshot,
    required this.salePriceSnapshot,
    required this.priceMode,
    required this.purchaseTier,
    required this.quantity,
    required this.profit,
    required this.margin,
    required this.soldAt,
    required this.monthKey,
    this.note,
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  double get revenue => salePriceSnapshot * quantity;
  double get totalCost => purchasePriceSnapshot * quantity;
  double get totalProfit => profit * quantity;

  static double calculateProfit({
    required double salePrice,
    required double purchasePrice,
    required int quantity,
  }) {
    return (salePrice - purchasePrice) * quantity;
  }

  static double calculateMargin({
    required double salePrice,
    required double purchasePrice,
  }) {
    if (salePrice <= 0) return 0;
    return ((salePrice - purchasePrice) / salePrice) * 100;
  }

  Sale copyWith({
    int? id,
    String? status,
    String? note,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId,
      sellerId: sellerId,
      productTitleSnapshot: productTitleSnapshot,
      sellerNameSnapshot: sellerNameSnapshot,
      purchasePriceSnapshot: purchasePriceSnapshot,
      salePriceSnapshot: salePriceSnapshot,
      priceMode: priceMode,
      purchaseTier: purchaseTier,
      quantity: quantity,
      profit: profit,
      margin: margin,
      soldAt: soldAt,
      monthKey: monthKey,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'seller_id': sellerId,
      'product_title_snapshot': productTitleSnapshot,
      'seller_name_snapshot': sellerNameSnapshot,
      'purchase_price_snapshot': purchasePriceSnapshot,
      'sale_price_snapshot': salePriceSnapshot,
      'price_mode': priceMode,
      'purchase_tier': purchaseTier,
      'quantity': quantity,
      'profit': profit,
      'margin': margin,
      'sold_at': soldAt.toIso8601String(),
      'month_key': monthKey,
      'note': note,
      'status': status,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      sellerId: map['seller_id'] as int,
      productTitleSnapshot: map['product_title_snapshot'] as String,
      sellerNameSnapshot: map['seller_name_snapshot'] as String,
      purchasePriceSnapshot: (map['purchase_price_snapshot'] as num).toDouble(),
      salePriceSnapshot: (map['sale_price_snapshot'] as num).toDouble(),
      priceMode: map['price_mode'] as String,
      purchaseTier: map['purchase_tier'] as int,
      quantity: map['quantity'] as int,
      profit: (map['profit'] as num).toDouble(),
      margin: (map['margin'] as num).toDouble(),
      soldAt: DateTime.parse(map['sold_at'] as String),
      monthKey: map['month_key'] as String,
      note: map['note'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }
}
