import 'package:flutter/material.dart';
import '../data/models/analytics_data.dart';
import '../data/repositories/sale_repository.dart';
import '../core/utils/formatters.dart';

class AnalyticsProvider extends ChangeNotifier {
  final SaleRepository _saleRepo;

  AnalyticsProvider(this._saleRepo);

  MonthlySummary? _summary;
  List<ProductSummary> _topProducts = [];
  List<SellerSummary> _sellerSummaries = [];
  Map<int, double> _dailyRevenue = {};
  List<String> _availableMonths = [];
  String _selectedMonthKey = AppFormatters.toMonthKey(DateTime.now());
  bool _isLoading = false;

  MonthlySummary? get summary => _summary;
  List<ProductSummary> get topProducts => _topProducts;
  List<SellerSummary> get sellerSummaries => _sellerSummaries;
  Map<int, double> get dailyRevenue => _dailyRevenue;
  List<String> get availableMonths => _availableMonths;
  String get selectedMonthKey => _selectedMonthKey;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _availableMonths = await _saleRepo.getAvailableMonths();
    if (_availableMonths.isNotEmpty &&
        !_availableMonths.contains(_selectedMonthKey)) {
      _selectedMonthKey = _availableMonths.first;
    }

    await _loadData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectMonth(String monthKey) async {
    _selectedMonthKey = monthKey;
    _isLoading = true;
    notifyListeners();
    await _loadData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _saleRepo.getMonthlySummary(_selectedMonthKey),
      _saleRepo.getTopProducts(_selectedMonthKey),
      _saleRepo.getSellerSummaries(_selectedMonthKey),
      _saleRepo.getDailyRevenue(_selectedMonthKey),
    ]);

    _summary = results[0] as MonthlySummary;
    _topProducts = results[1] as List<ProductSummary>;
    _sellerSummaries = results[2] as List<SellerSummary>;
    _dailyRevenue = results[3] as Map<int, double>;
  }

  Future<void> reload() async {
    _availableMonths = await _saleRepo.getAvailableMonths();
    await _loadData();
    notifyListeners();
  }
}
