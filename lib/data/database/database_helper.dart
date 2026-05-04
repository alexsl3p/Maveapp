import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mave_sales.db');
    return openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        uvp_price REAL NOT NULL,
        purchase_price_1 REAL NOT NULL,
        purchase_price_5 REAL NOT NULL,
        purchase_price_10 REAL NOT NULL,
        purchase_price_box REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sellers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        short_code TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        seller_id INTEGER NOT NULL DEFAULT 0,
        product_title_snapshot TEXT NOT NULL,
        seller_name_snapshot TEXT NOT NULL DEFAULT '',
        purchase_price_snapshot REAL NOT NULL,
        sale_price_snapshot REAL NOT NULL,
        price_mode TEXT NOT NULL,
        purchase_tier INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        profit REAL NOT NULL,
        margin REAL NOT NULL,
        sold_at TEXT NOT NULL,
        month_key TEXT NOT NULL,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        product_image_snapshot TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_sales_month ON sales (month_key)');
    await db.execute(
        'CREATE INDEX idx_sales_seller ON sales (seller_id)');
    await db.execute(
        'CREATE INDEX idx_sales_product ON sales (product_id)');

    await _createWarehouseTable(db);
  }

  Future<void> _createWarehouseTable(Database db) async {
    await db.execute('''
      CREATE TABLE warehouse_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity_total INTEGER NOT NULL,
        quantity_remaining INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        purchase_tier INTEGER NOT NULL,
        purchased_at TEXT NOT NULL,
        location TEXT NOT NULL DEFAULT 'home'
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_wh_product ON warehouse_entries (product_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE sales ADD COLUMN product_image_snapshot TEXT');
    }
    if (oldVersion < 3) {
      await _createWarehouseTable(db);
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE warehouse_entries ADD COLUMN location TEXT NOT NULL DEFAULT 'home'",
      );
    }
    if (oldVersion < 5) {
      final images = {
        'Molecular Oil Treatment 100ml':
            'assets/images/products/treatment_oil_100ml.png',
        'Organic Oil 30ml': 'assets/images/products/organic_oil_30ml.jpg',
        'Organic Paste Skin Repair 15ml':
            'assets/images/products/organic_paste.jpg',
        'Enzyme Scrub 400g': 'assets/images/products/enzyme_scrub_400g.jpg',
        'Invisible Mask': 'assets/images/products/invisible_mask.jpg',
        'Mizellen Reinigungsschaum 200ml':
            'assets/images/products/micellar_foam_200ml.jpg',
        'Mizellen Tücher': 'assets/images/products/micellar_wipes.jpg',
        '28 Cream': 'assets/images/products/cream_28_actives.jpg',
        'WOW SKIN SERUM PDRN 2 IN 1':
            'assets/images/products/wow_serum_pdrn.jpg',
        'WOW SKIN SERUM 2 IN 1':
            'assets/images/products/wow_serum_2in1.jpg',
        'EXPERT S.L.I.M.E': 'assets/images/products/slime_500g.jpg',
        'Molecular Shampoo & Conditioner Set':
            'assets/images/products/shampoo_conditioner.jpg',
        'Black Nanopowder + Nano360':
            'assets/images/products/black_nanopowder.jpg',
        'Taliora Shower Serum 500ml':
            'assets/images/products/taliora_shower_serum.jpg',
      };
      for (final entry in images.entries) {
        await db.execute(
          "UPDATE products SET image_url = ? WHERE title = ? AND (image_url IS NULL OR image_url = '')",
          [entry.value, entry.key],
        );
      }
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN purchase_price_box REAL NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
