import '../database/database_helper.dart';
import '../models/product.dart';
import '../mock/mock_data.dart';

class ProductRepository {
  final DatabaseHelper _db;

  ProductRepository(this._db);

  Future<List<Product>> getAll({bool activeOnly = false}) async {
    final db = await _db.database;
    final where = activeOnly ? 'WHERE is_active = 1' : '';
    final rows = await db.rawQuery(
      'SELECT * FROM products $where ORDER BY sort_order ASC, title ASC',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> insert(Product product) async {
    final db = await _db.database;
    return db.insert('products', product.toMap());
  }

  Future<void> update(Product product) async {
    final db = await _db.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> setActive(int id, bool isActive) async {
    final db = await _db.database;
    await db.update(
      'products',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isEmpty() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return (result.first['count'] as int) == 0;
  }

  Future<void> seedIfEmpty() async {
    if (!await isEmpty()) return;
    for (final product in MockData.products) {
      await insert(product);
    }
  }

  Future<List<String>> getCategories() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT category FROM products WHERE is_active = 1 ORDER BY category',
    );
    return rows.map((r) => r['category'] as String).toList();
  }
}
