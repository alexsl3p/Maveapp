import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/models/sale.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/sale_repository.dart';
import '../core/utils/formatters.dart';

class SalesProvider extends ChangeNotifier {
  final ProductRepository _productRepo;
  final SaleRepository _saleRepo;

  SalesProvider(this._productRepo, this._saleRepo);

  List<Product> _allProducts = [];
  List<Product> _filtered = [];
  List<String> _categories = [];
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;
  double _monthlyProfit = 0;
  int _monthlySalesCount = 0;

  List<Product> get products => _filtered;
  List<String> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get monthlyProfit => _monthlyProfit;
  int get monthlySalesCount => _monthlySalesCount;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _productRepo.seedIfEmpty();
    _allProducts = await _productRepo.getAll(activeOnly: true);
    _categories = await _productRepo.getCategories();
    _applyFilter();

    await _loadMonthlyStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMonthlyStats() async {
    final monthKey = AppFormatters.toMonthKey(DateTime.now());
    final summary = await _saleRepo.getMonthlySummary(monthKey);
    _monthlyProfit = summary.grossProfit;
    _monthlySalesCount = summary.salesCount;
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = _allProducts;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
    _filtered = list;
  }

  Future<void> saveSale(Sale sale) async {
    await _saleRepo.insert(sale);
    await _loadMonthlyStats();
    notifyListeners();
  }

  Future<void> reload() async {
    _allProducts = await _productRepo.getAll(activeOnly: true);
    _categories = await _productRepo.getCategories();
    _applyFilter();
    await _loadMonthlyStats();
    notifyListeners();
  }
}
