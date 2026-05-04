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

  // productId → total remaining units
  Future<Map<int, int>> getStockSummary() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT product_id, SUM(quantity_remaining) as total
      FROM warehouse_entries
      WHERE quantity_remaining > 0
      GROUP BY product_id
    ''');
    return {
      for (final r in rows)
        (r['product_id'] as int): (r['total'] as num).toInt(),
    };
  }

  Future<List<WarehouseEntry>> getEntriesForProduct(int productId) async {
    final db = await _db.database;
    final rows = await db.query(
      'warehouse_entries',
      where: 'product_id = ? AND quantity_remaining > 0',
      whereArgs: [productId],
      orderBy: 'purchased_at ASC',
    );
    return rows.map(WarehouseEntry.fromMap).toList();
  }

  // Returns weighted average purchase price without modifying DB
  Future<double> previewPrice(int productId, int quantity) async {
    final entries = await getEntriesForProduct(productId);
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
  Future<double> deductStock(int productId, int quantity) async {
    final db = await _db.database;
    final entries = await getEntriesForProduct(productId);
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
}
