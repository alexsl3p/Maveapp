class MonthlySummary {
  final String monthKey;
  final double revenue;
  final double totalCost;
  final double grossProfit;
  final double avgMargin;
  final int unitsSold;
  final int salesCount;

  const MonthlySummary({
    required this.monthKey,
    required this.revenue,
    required this.totalCost,
    required this.grossProfit,
    required this.avgMargin,
    required this.unitsSold,
    required this.salesCount,
  });

  static MonthlySummary empty(String monthKey) => MonthlySummary(
        monthKey: monthKey,
        revenue: 0,
        totalCost: 0,
        grossProfit: 0,
        avgMargin: 0,
        unitsSold: 0,
        salesCount: 0,
      );
}

class ProductSummary {
  final int productId;
  final String productTitle;
  final double totalProfit;
  final double totalRevenue;
  final int unitsSold;
  final double avgMargin;

  const ProductSummary({
    required this.productId,
    required this.productTitle,
    required this.totalProfit,
    required this.totalRevenue,
    required this.unitsSold,
    required this.avgMargin,
  });
}

class SellerSummary {
  final int sellerId;
  final String sellerName;
  final double totalProfit;
  final double totalRevenue;
  final int unitsSold;

  const SellerSummary({
    required this.sellerId,
    required this.sellerName,
    required this.totalProfit,
    required this.totalRevenue,
    required this.unitsSold,
  });
}
