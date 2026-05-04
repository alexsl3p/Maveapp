import 'package:flutter/material.dart';
import '../data/models/warehouse_entry.dart';
import '../data/repositories/warehouse_repository.dart';

class WarehouseProvider extends ChangeNotifier {
  final WarehouseRepository _repo;
  WarehouseProvider(this._repo);

  Map<int, int> _stock = {}; // productId → remaining units

  int stockFor(int productId) => _stock[productId] ?? 0;
  bool hasStock(int productId) => stockFor(productId) > 0;
  Map<int, int> get allStock => _stock;

  Future<void> load() async {
    _stock = await _repo.getStockSummary();
    notifyListeners();
  }

  Future<void> addStock(
    int productId,
    int quantity,
    int tier,
    double price,
  ) async {
    await _repo.addEntry(WarehouseEntry(
      productId: productId,
      quantityTotal: quantity,
      quantityRemaining: quantity,
      purchasePrice: price,
      purchaseTier: tier,
      purchasedAt: DateTime.now(),
    ));
    _stock[productId] = (_stock[productId] ?? 0) + quantity;
    notifyListeners();
  }

  Future<double> previewPrice(int productId, int quantity) =>
      _repo.previewPrice(productId, quantity);

  Future<double> deductAndGetPrice(int productId, int quantity) async {
    final price = await _repo.deductStock(productId, quantity);
    final current = _stock[productId] ?? 0;
    _stock[productId] = (current - quantity).clamp(0, current);
    notifyListeners();
    return price;
  }
}
