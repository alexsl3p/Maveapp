import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class ProfitBarChart extends StatelessWidget {
  final Map<int, double> dailyRevenue;
  final int daysInMonth;

  const ProfitBarChart({
    super.key,
    required this.dailyRevenue,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Нет данных',
            style: AppTypography.bodySmall,
          ),
        ),
      );
    }

    final maxY = dailyRevenue.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.deepText,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  AppFormatters.price(rod.toY),
                  AppTypography.bodySmall.copyWith(
                    color: AppColors.lightCream,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt();
                  if (day % 5 != 0) return const SizedBox.shrink();
                  return Text(
                    '$day',
                    style: AppTypography.overline.copyWith(fontSize: 9),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider,
              strokeWidth: 0.5,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(daysInMonth, (index) {
            final day = index + 1;
            final revenue = dailyRevenue[day] ?? 0.0;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: revenue,
                  color: revenue > 0
                      ? AppColors.accentBrown
                      : AppColors.divider,
                  width: revenue > 0 ? 8 : 4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
