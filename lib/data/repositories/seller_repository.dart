import '../database/database_helper.dart';
import '../models/seller.dart';
import '../mock/mock_data.dart';

class SellerRepository {
  final DatabaseHelper _db;

  SellerRepository(this._db);

  Future<List<Seller>> getAll({bool activeOnly = false}) async {
    final db = await _db.database;
    final where = activeOnly ? 'WHERE is_active = 1' : '';
    final rows = await db.rawQuery(
      'SELECT * FROM sellers $where ORDER BY name ASC',
    );
    return rows.map(Seller.fromMap).toList();
  }

  Future<Seller?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('sellers', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Seller.fromMap(rows.first);
  }

  Future<int> insert(Seller seller) async {
    final db = await _db.database;
    return db.insert('sellers', seller.toMap());
  }

  Future<void> update(Seller seller) async {
    final db = await _db.database;
    await db.update(
      'sellers',
      seller.toMap(),
      where: 'id = ?',
      whereArgs: [seller.id],
    );
  }

  Future<void> setActive(int id, bool isActive) async {
    final db = await _db.database;
    await db.update(
      'sellers',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isEmpty() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sellers');
    return (result.first['count'] as int) == 0;
  }

  Future<void> seedIfEmpty() async {
    if (!await isEmpty()) return;
    for (final seller in MockData.sellers) {
      await insert(seller);
    }
  }
}
