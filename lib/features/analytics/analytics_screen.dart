import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/analytics_provider.dart';
import '../../data/models/analytics_data.dart';
import 'widgets/kpi_card.dart';
import 'widgets/profit_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AnalyticsView();
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  int _daysInMonth(String monthKey) {
    final date = AppFormatters.fromMonthKey(monthKey);
    return DateTime(date.year, date.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<AnalyticsProvider>(
          builder: (context, analytics, _) {
            if (analytics.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, analytics),
                _buildKpiGrid(analytics),
                _buildChart(analytics),
                _buildTopProducts(analytics),
                _buildSellerStats(analytics),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAppBar(
      BuildContext context, AnalyticsProvider analytics) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.analyticsTitle,
              style: AppTypography.displayMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            if (analytics.availableMonths.isNotEmpty)
              _MonthPicker(
                months: analytics.availableMonths,
                selected: analytics.selectedMonthKey,
                onSelected: analytics.selectMonth,
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildKpiGrid(AnalyticsProvider analytics) {
    final summary = analytics.summary;
    if (summary == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(AppStrings.noData, style: AppTypography.bodyMedium),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            // Gross profit — wide card
            KpiCard(
              label: AppStrings.grossProfit,
              value: AppFormatters.price(summary.grossProfit),
              sublabel: '${summary.salesCount} продаж · ${summary.unitsSold} единиц',
              valueColor: AppColors.success,
              backgroundColor: AppColors.successLight,
              icon: Icons.trending_up,
              isWide: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: AppStrings.revenue,
                    value: AppFormatters.price(summary.revenue),
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiCard(
                    label: AppStrings.cost,
                    value: AppFormatters.price(summary.totalCost),
                    icon: Icons.shopping_cart_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: AppStrings.avgMargin,
                    value: AppFormatters.percent(summary.avgMargin),
                    icon: Icons.percent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiCard(
                    label: AppStrings.unitsSold,
                    value: '${summary.unitsSold}',
                    sublabel: 'штук',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildChart(AnalyticsProvider analytics) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.dailyChart, style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            ProfitBarChart(
              dailyRevenue: analytics.dailyRevenue,
              daysInMonth: _daysInMonth(analytics.selectedMonthKey),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTopProducts(AnalyticsProvider analytics) {
    if (analytics.topProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.topProducts, style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            ...analytics.topProducts.asMap().entries.map(
                  (entry) => _TopProductTile(
                    rank: entry.key + 1,
                    summary: entry.value,
                    maxProfit: analytics.topProducts.first.totalProfit,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSellerStats(AnalyticsProvider analytics) {
    if (analytics.sellerSummaries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.topSellers, style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            ...analytics.sellerSummaries.map(
              (seller) => _SellerStatTile(summary: seller),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final int rank;
  final ProductSummary summary;
  final double maxProfit;

  const _TopProductTile({
    required this.rank,
    required this.summary,
    required this.maxProfit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxProfit > 0 ? (summary.totalProfit / maxProfit) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? const Color(0xFFD4A94A)
                      : rank == 2
                          ? const Color(0xFF9AA8B0)
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: AppTypography.labelLarge.copyWith(
                      color: rank <= 2 ? Colors.white : AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary.productTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                AppFormatters.price(summary.totalProfit),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio.toDouble(),
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentBrown,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${summary.unitsSold} шт · ${AppFormatters.percent(summary.avgMargin)}',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SellerStatTile extends StatelessWidget {
  final SellerSummary summary;

  const _SellerStatTile({required this.summary});

  String get _initials {
    final parts = summary.sellerName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return summary.sellerName.isNotEmpty
        ? summary.sellerName[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.accentBrown,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.lightCream,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.sellerName,
                  style: AppTypography.titleSmall,
                ),
                Text(
                  '${summary.unitsSold} шт · ${AppFormatters.price(summary.totalRevenue)} оборот',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.price(summary.totalProfit),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'прибыль',
                style: AppTypography.overline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final List<String> months;
  final String selected;
  final ValueChanged<String> onSelected;

  const _MonthPicker({
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
              AppFormatters.monthKeyToDisplay(selected),
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
