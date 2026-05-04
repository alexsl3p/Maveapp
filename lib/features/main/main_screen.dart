import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/warehouse_provider.dart';
import '../sales/sales_screen.dart';
import '../history/history_screen.dart';
import '../analytics/analytics_screen.dart';
import '../catalog/catalog_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(Icons.shopping_bag),
      label: AppStrings.navSales,
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: AppStrings.navHistory,
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: AppStrings.navAnalytics,
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: AppStrings.navCatalog,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
      context.read<SalesProvider>().init();
      context.read<WarehouseProvider>().load();
    });
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    _loadTabData(index);
  }

  void _loadTabData(int index) {
    switch (index) {
      case 1:
        context.read<HistoryProvider>().load();
      case 2:
        context.read<AnalyticsProvider>().load();
      case 3:
        context.read<CatalogProvider>().load();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          SalesScreen(),
          HistoryScreen(),
          AnalyticsScreen(),
          CatalogScreen(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: _destinations,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
