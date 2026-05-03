import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/history_provider.dart';
import '../../providers/app_provider.dart';
import 'widgets/sale_list_item.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HistoryView();
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer2<HistoryProvider, AppProvider>(
          builder: (context, history, app, _) {
            if (history.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, history),
                _buildFilters(context, history, app),
                _buildSalesList(context, history),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAppBar(
      BuildContext context, HistoryProvider history) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.historyTitle, style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w600)),
            if (history.months.isNotEmpty)
              _MonthDropdown(
                months: history.months,
                selected: history.selectedMonth,
                onSelected: history.setMonth,
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilters(
    BuildContext context,
    HistoryProvider history,
    AppProvider app,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: AppStrings.allSellers,
                isSelected: history.selectedSellerId == null,
                onTap: () => history.setSeller(null),
              ),
              const SizedBox(width: 8),
              ...app.sellers.map((seller) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: seller.name.split(' ').first,
                      isSelected: history.selectedSellerId == seller.id,
                      onTap: () => history.setSeller(seller.id),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesList(BuildContext context, HistoryProvider history) {
    if (history.grouped.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: AppColors.mutedText.withOpacity(0.4),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.noSales,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.noSalesHint,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final entries = history.grouped.entries.toList();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, groupIndex) {
          final entry = entries[groupIndex];
          final monthKey = entry.key;
          final sales = entry.value;
          final monthRevenue = sales.fold<double>(
            0,
            (sum, s) => sum + s.salePriceSnapshot * s.quantity,
          );
          final monthProfit = sales.fold<double>(0, (sum, s) => sum + s.profit);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MonthGroupHeader(
                  monthKey: monthKey,
                  revenue: monthRevenue,
                  profit: monthProfit,
                  count: sales.length,
                ),
                const SizedBox(height: 12),
                ...sales.map(
                  (sale) => SaleListItem(
                    sale: sale,
                    onCancel: sale.isActive
                        ? () => context
                            .read<HistoryProvider>()
                            .cancelSale(sale.id!)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }
}

class _MonthGroupHeader extends StatelessWidget {
  final String monthKey;
  final double revenue;
  final double profit;
  final int count;

  const _MonthGroupHeader({
    required this.monthKey,
    required this.revenue,
    required this.profit,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppFormatters.monthKeyToDisplay(monthKey),
              style: AppTypography.titleMedium,
            ),
            Text(
              '$count продаж',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.price(revenue),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.deepText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${AppFormatters.price(profit)} прибыль',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  final List<String> months;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _MonthDropdown({
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected != null
                  ? AppFormatters.monthKeyToDisplay(selected!)
                  : 'Все месяцы',
              style: AppTypography.labelLarge.copyWith(fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Выберите месяц', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Все месяцы', style: AppTypography.titleSmall),
              trailing: selected == null
                  ? const Icon(Icons.check, color: AppColors.accentBrown)
                  : null,
              onTap: () {
                onSelected(null);
                Navigator.pop(context);
              },
            ),
            ...months.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppFormatters.monthKeyToDisplay(m),
                  style: AppTypography.titleSmall,
                ),
                trailing: selected == m
                    ? const Icon(Icons.check, color: AppColors.accentBrown)
                    : null,
                onTap: () {
                  onSelected(m);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBrown : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? AppColors.lightCream : AppColors.deepText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
