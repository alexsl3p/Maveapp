import '../database/database_helper.dart';
import '../models/sale.dart';
import '../models/analytics_data.dart';

class SaleRepository {
  final DatabaseHelper _db;

  SaleRepository(this._db);

  Future<int> insert(Sale sale) async {
    final db = await _db.database;
    return db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getByMonth(String monthKey, {int? sellerId}) async {
    final db = await _db.database;
    String where = "month_key = ? AND status = 'active'";
    List<dynamic> args = [monthKey];
    if (sellerId != null) {
      where += ' AND seller_id = ?';
      args.add(sellerId);
    }
    final rows = await db.query(
      'sales',
      where: where,
      whereArgs: args,
      orderBy: 'sold_at DESC',
    );
    return rows.map(Sale.fromMap).toList();
  }

  Future<List<Sale>> getAll({int? sellerId, int? productId}) async {
    final db = await _db.database;
    String where = "status = 'active'";
    List<dynamic> args = [];
    if (sellerId != null) {
      where += ' AND seller_id = ?';
      args.add(sellerId);
    }
    if (productId != null) {
      where += ' AND product_id = ?';
      args.add(productId);
    }
    final rows = await db.query(
      'sales',
      where: where,
      whereArgs: args,
      orderBy: 'sold_at DESC',
    );
    return rows.map(Sale.fromMap).toList();
  }

  Future<void> cancel(int id) async {
    final db = await _db.database;
    await db.update(
      'sales',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAvailableMonths() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      "SELECT DISTINCT month_key FROM sales WHERE status = 'active' ORDER BY month_key DESC",
    );
    return rows.map((r) => r['month_key'] as String).toList();
  }

  Future<MonthlySummary> getMonthlySummary(String monthKey) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT
        SUM(sale_price_snapshot * quantity) as revenue,
        SUM(purchase_price_snapshot * quantity) as total_cost,
        SUM(profit) as gross_profit,
        AVG(margin) as avg_margin,
        SUM(quantity) as units_sold,
        COUNT(*) as sales_count
      FROM sales
      WHERE month_key = ? AND status = 'active'
    ''', [monthKey]);

    if (rows.isEmpty || rows.first['revenue'] == null) {
      return MonthlySummary.empty(monthKey);
    }

    final row = rows.first;
    return MonthlySummary(
      monthKey: monthKey,
      revenue: (row['revenue'] as num?)?.toDouble() ?? 0,
      totalCost: (row['total_cost'] as num?)?.toDouble() ?? 0,
      grossProfit: (row['gross_profit'] as num?)?.toDouble() ?? 0,
      avgMargin: (row['avg_margin'] as num?)?.toDouble() ?? 0,
      unitsSold: (row['units_sold'] as num?)?.toInt() ?? 0,
      salesCount: (row['sales_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<ProductSummary>> getTopProducts(
    String monthKey, {
    int limit = 5,
  }) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT
        product_id,
        product_title_snapshot,
        SUM(profit) as total_profit,
        SUM(sale_price_snapshot * quantity) as total_revenue,
        SUM(quantity) as units_sold,
        AVG(margin) as avg_margin
      FROM sales
      WHERE month_key = ? AND status = 'active'
      GROUP BY product_id, product_title_snapshot
      ORDER BY total_profit DESC
      LIMIT ?
    ''', [monthKey, limit]);

    return rows
        .map((r) => ProductSummary(
              productId: r['product_id'] as int,
              productTitle: r['product_title_snapshot'] as String,
              totalProfit: (r['total_profit'] as num).toDouble(),
              totalRevenue: (r['total_revenue'] as num).toDouble(),
              unitsSold: (r['units_sold'] as num).toInt(),
              avgMargin: (r['avg_margin'] as num).toDouble(),
            ))
        .toList();
  }

  Future<List<SellerSummary>> getSellerSummaries(String monthKey) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT
        seller_id,
        seller_name_snapshot,
        SUM(profit) as total_profit,
        SUM(sale_price_snapshot * quantity) as total_revenue,
        SUM(quantity) as units_sold
      FROM sales
      WHERE month_key = ? AND status = 'active'
      GROUP BY seller_id, seller_name_snapshot
      ORDER BY total_profit DESC
    ''', [monthKey]);

    return rows
        .map((r) => SellerSummary(
              sellerId: r['seller_id'] as int,
              sellerName: r['seller_name_snapshot'] as String,
              totalProfit: (r['total_profit'] as num).toDouble(),
              totalRevenue: (r['total_revenue'] as num).toDouble(),
              unitsSold: (r['units_sold'] as num).toInt(),
            ))
        .toList();
  }

  (String, List<dynamic>) _buildDateFilter({DateTime? from, DateTime? to}) {
    String where = "status = 'active'";
    final List<dynamic> args = [];
    if (from != null && to != null) {
      final fromStr =
          '${from.year.toString().padLeft(4, '0')}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      final toStr =
          '${to.year.toString().padLeft(4, '0')}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')} 23:59:59';
      where += ' AND sold_at >= ? AND sold_at <= ?';
      args.add(fromStr);
      args.add(toStr);
    }
    return (where, args);
  }

  Future<MonthlySummary> getSummaryFiltered({DateTime? from, DateTime? to}) async {
    final db = await _db.database;
    final (where, args) = _buildDateFilter(from: from, to: to);
    final rows = await db.rawQuery('''
      SELECT
        SUM(sale_price_snapshot * quantity) as revenue,
        SUM(purchase_price_snapshot * quantity) as total_cost,
        SUM(profit) as gross_profit,
        AVG(margin) as avg_margin,
        SUM(quantity) as units_sold,
        COUNT(*) as sales_count
      FROM sales
      WHERE $where
    ''', args);

    if (rows.isEmpty || rows.first['revenue'] == null) {
      return MonthlySummary.empty('all');
    }
    final row = rows.first;
    return MonthlySummary(
      monthKey: 'all',
      revenue: (row['revenue'] as num?)?.toDouble() ?? 0,
      totalCost: (row['total_cost'] as num?)?.toDouble() ?? 0,
      grossProfit: (row['gross_profit'] as num?)?.toDouble() ?? 0,
      avgMargin: (row['avg_margin'] as num?)?.toDouble() ?? 0,
      unitsSold: (row['units_sold'] as num?)?.toInt() ?? 0,
      salesCount: (row['sales_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<ProductSummary>> getTopProductsFiltered({
    DateTime? from,
    DateTime? to,
    int limit = 5,
  }) async {
    final db = await _db.database;
    final (where, args) = _buildDateFilter(from: from, to: to);
    final rows = await db.rawQuery('''
      SELECT
        product_id,
        product_title_snapshot,
        SUM(profit) as total_profit,
        SUM(sale_price_snapshot * quantity) as total_revenue,
        SUM(quantity) as units_sold,
        AVG(margin) as avg_margin
      FROM sales
      WHERE $where
      GROUP BY product_id, product_title_snapshot
      ORDER BY total_profit DESC
      LIMIT ?
    ''', [...args, limit]);

    return rows
        .map((r) => ProductSummary(
              productId: r['product_id'] as int,
              productTitle: r['product_title_snapshot'] as String,
              totalProfit: (r['total_profit'] as num).toDouble(),
              totalRevenue: (r['total_revenue'] as num).toDouble(),
              unitsSold: (r['units_sold'] as num).toInt(),
              avgMargin: (r['avg_margin'] as num).toDouble(),
            ))
        .toList();
  }

  Future<List<SellerSummary>> getSellerSummariesFiltered({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db.database;
    final (where, args) = _buildDateFilter(from: from, to: to);
    final rows = await db.rawQuery('''
      SELECT
        seller_id,
        seller_name_snapshot,
        SUM(profit) as total_profit,
        SUM(sale_price_snapshot * quantity) as total_revenue,
        SUM(quantity) as units_sold
      FROM sales
      WHERE $where
      GROUP BY seller_id, seller_name_snapshot
      ORDER BY total_profit DESC
    ''', args);

    return rows
        .map((r) => SellerSummary(
              sellerId: r['seller_id'] as int,
              sellerName: r['seller_name_snapshot'] as String,
              totalProfit: (r['total_profit'] as num).toDouble(),
              totalRevenue: (r['total_revenue'] as num).toDouble(),
              unitsSold: (r['units_sold'] as num).toInt(),
            ))
        .toList();
  }

  Future<Map<int, double>> getDailyRevenue(String monthKey) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT
        CAST(strftime('%d', sold_at) AS INTEGER) as day,
        SUM(sale_price_snapshot * quantity) as revenue
      FROM sales
      WHERE month_key = ? AND status = 'active'
      GROUP BY day
      ORDER BY day
    ''', [monthKey]);

    return {
      for (final r in rows)
        (r['day'] as int): (r['revenue'] as num).toDouble(),
    };
  }
}
