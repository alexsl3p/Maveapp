class WarehouseEntry {
  final int? id;
  final int productId;
  final int quantityTotal;
  final int quantityRemaining;
  final double purchasePrice;
  final int purchaseTier;
  final DateTime purchasedAt;
  final String location; // 'home' | 'salon'

  const WarehouseEntry({
    this.id,
    required this.productId,
    required this.quantityTotal,
    required this.quantityRemaining,
    required this.purchasePrice,
    required this.purchaseTier,
    required this.purchasedAt,
    this.location = 'home',
  });

  WarehouseEntry copyWith({int? quantityRemaining}) => WarehouseEntry(
        id: id,
        productId: productId,
        quantityTotal: quantityTotal,
        quantityRemaining: quantityRemaining ?? this.quantityRemaining,
        purchasePrice: purchasePrice,
        purchaseTier: purchaseTier,
        purchasedAt: purchasedAt,
        location: location,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'product_id': productId,
        'quantity_total': quantityTotal,
        'quantity_remaining': quantityRemaining,
        'purchase_price': purchasePrice,
        'purchase_tier': purchaseTier,
        'purchased_at': purchasedAt.toIso8601String(),
        'location': location,
      };

  factory WarehouseEntry.fromMap(Map<String, dynamic> m) => WarehouseEntry(
        id: m['id'] as int?,
        productId: m['product_id'] as int,
        quantityTotal: m['quantity_total'] as int,
        quantityRemaining: m['quantity_remaining'] as int,
        purchasePrice: (m['purchase_price'] as num).toDouble(),
        purchaseTier: m['purchase_tier'] as int,
        purchasedAt: DateTime.parse(m['purchased_at'] as String),
        location: (m['location'] as String?) ?? 'home',
      );
}
