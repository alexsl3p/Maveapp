import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_strings.dart';

class MonthlySummaryCard extends StatelessWidget {
  final double monthlyProfit;
  final int salesCount;
  final String monthKey;

  const MonthlySummaryCard({
    super.key,
    required this.monthlyProfit,
    required this.salesCount,
    required this.monthKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBrown,
            AppColors.accentBrown.withOpacity(0.82),
            AppColors.sageGreen.withOpacity(0.9),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBrown.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.monthlyProfit,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                AppFormatters.monthKeyToDisplay(monthKey),
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppFormatters.price(monthlyProfit),
            style: AppTypography.priceDisplay.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w200,
              fontSize: 36,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 0.5,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricChip(
                label: AppStrings.monthlySales,
                value: '$salesCount',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.65)),
        const SizedBox(width: 6),
        Text(
          '$value ',
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}
