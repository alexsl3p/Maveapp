import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            return CustomScrollView(
              slivers: [
                _buildHeader(context, analytics),
                if (analytics.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentBrown),
                      ),
                    ),
                  )
                else if (analytics.availableMonths.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_outlined,
                              size: 52,
                              color: AppColors.mutedText.withOpacity(0.4)),
                          const SizedBox(height: 14),
                          Text(AppStrings.noData,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.mutedText)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildKpiGrid(analytics),
                  _buildChart(analytics),
                  _buildTopProducts(analytics),
                  _buildSellerStats(analytics),
                  const SliverPadding(
                      padding: EdgeInsets.only(bottom: 100)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header with month arrow navigator ────────────────────────────────────
  SliverToBoxAdapter _buildHeader(
      BuildContext context, AnalyticsProvider analytics) {
    final months = analytics.availableMonths;
    final selected = analytics.selectedMonthKey;
    final idx = months.indexOf(selected);
    final hasPrev = idx < months.length - 1;
    final hasNext = idx > 0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.analyticsTitle,
              style: AppTypography.displayMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            if (months.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    _NavArrow(
                      icon: Icons.chevron_left,
                      enabled: hasPrev,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        analytics.selectMonth(months[idx + 1]);
                      },
                    ),
                    Expanded(
                      child: Text(
                        AppFormatters.monthKeyToDisplay(selected),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _NavArrow(
                      icon: Icons.chevron_right,
                      enabled: hasNext,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        analytics.selectMonth(months[idx - 1]);
                      },
                    ),
                  ],
                ),
              ),
              if (months.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _MonthDots(
                    months: months,
                    selectedIndex: idx,
                    onTap: (i) => analytics.selectMonth(months[i]),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ── KPI cards ─────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildKpiGrid(AnalyticsProvider analytics) {
    final summary = analytics.summary;
    if (summary == null || summary.salesCount == 0) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(AppStrings.noData,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.mutedText)),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            KpiCard(
              label: AppStrings.grossProfit,
              value: AppFormatters.price(summary.grossProfit),
              sublabel:
                  '${summary.salesCount} продаж · ${summary.unitsSold} единиц',
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
    if (analytics.dailyRevenue.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
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
    if (analytics.topProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
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
            ...analytics.sellerSummaries
                .map((s) => _SellerStatTile(summary: s)),
          ],
        ),
      ),
    );
  }
}

// ── Month navigation arrow button ─────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.deepText : AppColors.divider,
        ),
      ),
    );
  }
}

// ── Dot indicators below month navigator ─────────────────────────────────
class _MonthDots extends StatelessWidget {
  final List<String> months;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MonthDots({
    required this.months,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(months.length, (i) {
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isSelected ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentBrown
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ── Top product tile ──────────────────────────────────────────────────────
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
              offset: const Offset(0, 1)),
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
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
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
                        AppColors.accentBrown),
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

// ── Seller stat tile ──────────────────────────────────────────────────────
class _SellerStatTile extends StatelessWidget {
  final SellerSummary summary;

  const _SellerStatTile({required this.summary});

  String get _initials {
    final parts = summary.sellerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
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
              offset: const Offset(0, 1)),
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
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.lightCream, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.sellerName, style: AppTypography.titleSmall),
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
                    color: AppColors.success, fontWeight: FontWeight.w600),
              ),
              Text('прибыль', style: AppTypography.overline),
            ],
          ),
        ],
      ),
    );
  }
}
