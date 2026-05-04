import 'package:flutter/material.dart';
import '../data/models/warehouse_entry.dart';
import '../data/repositories/warehouse_repository.dart';

class WarehouseProvider extends ChangeNotifier {
  final WarehouseRepository _repo;
  WarehouseProvider(this._repo);

  // {productId: {location: qty}}
  Map<int, Map<String, int>> _stock = {};

  int stockFor(int productId, String location) =>
      _stock[productId]?[location] ?? 0;

  int totalStockFor(int productId) =>
      _stock[productId]?.values.fold<int>(0, (a, b) => a + b) ?? 0;

  bool hasStock(int productId) => totalStockFor(productId) > 0;

  bool hasStockAt(int productId, String location) =>
      stockFor(productId, location) > 0;

  Map<String, int> stockByLocation(int productId) =>
      _stock[productId] ?? {};

  List<String> locationsWithStock(int productId) {
    final m = _stock[productId];
    if (m == null) return [];
    return m.entries.where((e) => e.value > 0).map((e) => e.key).toList();
  }

  Future<void> load() async {
    _stock = await _repo.getStockSummary();
    notifyListeners();
  }

  Future<void> addStock(
    int productId,
    int quantity,
    int tier,
    double price,
    String location,
  ) async {
    await _repo.addEntry(WarehouseEntry(
      productId: productId,
      quantityTotal: quantity,
      quantityRemaining: quantity,
      purchasePrice: price,
      purchaseTier: tier,
      purchasedAt: DateTime.now(),
      location: location,
    ));
    _stock.putIfAbsent(productId, () => {})[location] =
        (_stock[productId]?[location] ?? 0) + quantity;
    notifyListeners();
  }

  Future<double> previewPrice(
          int productId, int quantity, String location) =>
      _repo.previewPrice(productId, quantity, location);

  Future<double> deductAndGetPrice(
      int productId, int quantity, String location) async {
    final price = await _repo.deductStock(productId, quantity, location);
    final current = _stock[productId]?[location] ?? 0;
    _stock.putIfAbsent(productId, () => {})[location] =
        (current - quantity).clamp(0, current);
    notifyListeners();
    return price;
  }

  // Transfer units from home → salon, preserving cost basis
  Future<void> transfer(int productId, int quantity) async {
    await _repo.transfer(productId, quantity);
    final homeStock = _stock[productId]?['home'] ?? 0;
    _stock.putIfAbsent(productId, () => {})['home'] =
        (homeStock - quantity).clamp(0, homeStock);
    final salonStock = _stock[productId]?['salon'] ?? 0;
    _stock.putIfAbsent(productId, () => {})['salon'] = salonStock + quantity;
    notifyListeners();
  }
}
