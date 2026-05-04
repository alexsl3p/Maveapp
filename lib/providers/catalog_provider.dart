import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final ProductRepository _productRepo;

  CatalogProvider(this._productRepo);

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _products = await _productRepo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _productRepo.insert(product);
    await load();
  }

  Future<void> updateProduct(Product product) async {
    await _productRepo.update(product);
    await load();
  }

  Future<void> reorderProducts(int oldIndex, int newIndex) async {
    final list = List<Product>.from(_products);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _products = list;
    notifyListeners();
    await _productRepo.updateSortOrders(list.map((p) => p.id!).toList());
  }

  Future<void> deleteProduct(int id) async {
    await _productRepo.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> toggleActive(int id, bool isActive) async {
    await _productRepo.setActive(id, isActive);
    _products = _products
        .map((p) => p.id == id ? p.copyWith(isActive: isActive) : p)
        .toList();
    notifyListeners();
  }
}
