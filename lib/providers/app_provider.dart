import 'package:flutter/material.dart';
import '../data/models/seller.dart';
import '../data/repositories/seller_repository.dart';

class AppProvider extends ChangeNotifier {
  final SellerRepository _sellerRepo;

  AppProvider(this._sellerRepo);

  List<Seller> _sellers = [];
  Seller? _currentSeller;
  bool _isDarkMode = false;
  bool _isLoading = false;

  List<Seller> get sellers => _sellers;
  Seller? get currentSeller => _currentSeller;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _sellerRepo.seedIfEmpty();
    _sellers = await _sellerRepo.getAll(activeOnly: true);
    if (_sellers.isNotEmpty && _currentSeller == null) {
      _currentSeller = _sellers.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadSellers() async {
    _sellers = await _sellerRepo.getAll(activeOnly: true);
    if (_currentSeller != null) {
      final updated = _sellers.firstWhere(
        (s) => s.id == _currentSeller!.id,
        orElse: () => _sellers.isNotEmpty ? _sellers.first : _currentSeller!,
      );
      _currentSeller = updated;
    } else if (_sellers.isNotEmpty) {
      _currentSeller = _sellers.first;
    }
    notifyListeners();
  }

  void setCurrentSeller(Seller seller) {
    _currentSeller = seller;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> addSeller(String name, String shortCode) async {
    await _sellerRepo.insert(Seller(name: name, shortCode: shortCode));
    await reloadSellers();
  }

  Future<void> toggleSellerActive(int id, bool isActive) async {
    await _sellerRepo.setActive(id, isActive);
    await reloadSellers();
  }
}
