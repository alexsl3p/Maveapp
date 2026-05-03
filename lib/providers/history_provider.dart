import 'package:flutter/material.dart';
import '../data/models/sale.dart';
import '../data/repositories/sale_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final SaleRepository _saleRepo;

  HistoryProvider(this._saleRepo);

  List<Sale> _allSales = [];
  Map<String, List<Sale>> _grouped = {};
  List<String> _months = [];
  String? _selectedMonth;
  int? _selectedSellerId;
  int? _selectedProductId;
  bool _isLoading = false;

  Map<String, List<Sale>> get grouped => _grouped;
  List<String> get months => _months;
  String? get selectedMonth => _selectedMonth;
  int? get selectedSellerId => _selectedSellerId;
  bool get isLoading => _isLoading;
  int get totalCount => _allSales.length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _months = await _saleRepo.getAvailableMonths();
    if (_selectedMonth == null && _months.isNotEmpty) {
      _selectedMonth = _months.first;
    }

    await _reloadSales();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadSales() async {
    if (_selectedMonth != null) {
      _allSales = await _saleRepo.getByMonth(
        _selectedMonth!,
        sellerId: _selectedSellerId,
      );
    } else {
      _allSales = await _saleRepo.getAll(
        sellerId: _selectedSellerId,
        productId: _selectedProductId,
      );
    }
    _buildGrouped();
  }

  void _buildGrouped() {
    _grouped = {};
    for (final sale in _allSales) {
      _grouped.putIfAbsent(sale.monthKey, () => []).add(sale);
    }
  }

  Future<void> setMonth(String? monthKey) async {
    _selectedMonth = monthKey;
    _isLoading = true;
    notifyListeners();
    await _reloadSales();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setSeller(int? sellerId) async {
    _selectedSellerId = sellerId;
    _isLoading = true;
    notifyListeners();
    await _reloadSales();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelSale(int id) async {
    await _saleRepo.cancel(id);
    _months = await _saleRepo.getAvailableMonths();
    await _reloadSales();
    notifyListeners();
  }

  Future<void> reload() async {
    _months = await _saleRepo.getAvailableMonths();
    await _reloadSales();
    notifyListeners();
  }
}
