import 'dart:math';
import '../database/database_helper.dart';
import '../models/warehouse_entry.dart';

class WarehouseRepository {
  final DatabaseHelper _db;
  WarehouseRepository(this._db);

  Future<void> addEntry(WarehouseEntry entry) async {
    final db = await _db.database;
    await db.insert('warehouse_entries', entry.toMap());
  }

  // Returns {productId: {location: qty}}
  Future<Map<int, Map<String, int>>> getStockSummary() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT product_id, location, SUM(quantity_remaining) as total
      FROM warehouse_entries
      WHERE quantity_remaining > 0
      GROUP BY product_id, location
    ''');
    final result = <int, Map<String, int>>{};
    for (final r in rows) {
      final pid = r['product_id'] as int;
      final loc = (r['location'] as String?) ?? 'home';
      final qty = (r['total'] as num).toInt();
      result.putIfAbsent(pid, () => {})[loc] = qty;
    }
    return result;
  }

  Future<List<WarehouseEntry>> getEntriesForProduct(
      int productId, String location) async {
    final db = await _db.database;
    final rows = await db.query(
      'warehouse_entries',
      where: 'product_id = ? AND location = ? AND quantity_remaining > 0',
      whereArgs: [productId, location],
      orderBy: 'purchased_at ASC',
    );
    return rows.map(WarehouseEntry.fromMap).toList();
  }

  // Weighted average price preview (no DB write)
  Future<double> previewPrice(
      int productId, int quantity, String location) async {
    final entries = await getEntriesForProduct(productId, location);
    double totalCost = 0;
    int remaining = quantity;
    for (final e in entries) {
      if (remaining <= 0) break;
      final take = min(remaining, e.quantityRemaining);
      totalCost += take * e.purchasePrice;
      remaining -= take;
    }
    final consumed = quantity - remaining;
    return consumed > 0 ? totalCost / consumed : 0;
  }

  // FIFO deduction — returns weighted avg purchase price per unit
  Future<double> deductStock(
      int productId, int quantity, String location) async {
    final db = await _db.database;
    final entries = await getEntriesForProduct(productId, location);
    double totalCost = 0;
    int remaining = quantity;
    for (final e in entries) {
      if (remaining <= 0) break;
      final take = min(remaining, e.quantityRemaining);
      totalCost += take * e.purchasePrice;
      remaining -= take;
      await db.update(
        'warehouse_entries',
        {'quantity_remaining': e.quantityRemaining - take},
        where: 'id = ?',
        whereArgs: [e.id],
      );
    }
    final consumed = quantity - remaining;
    return consumed > 0 ? totalCost / consumed : 0;
  }

  // Transfer units from home → salon preserving cost basis
  Future<double> transfer(int productId, int quantity) async {
    final price = await deductStock(productId, quantity, 'home');
    await addEntry(WarehouseEntry(
      productId: productId,
      quantityTotal: quantity,
      quantityRemaining: quantity,
      purchasePrice: price,
      purchaseTier: 0,
      purchasedAt: DateTime.now(),
      location: 'salon',
    ));
    return price;
  }
}
