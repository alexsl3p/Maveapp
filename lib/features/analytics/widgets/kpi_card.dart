import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final Color? valueColor;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isWide;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.valueColor,
    this.backgroundColor,
    this.icon,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.mutedText),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.overline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.kpiValue.copyWith(
              color: valueColor ?? AppColors.deepText,
              fontSize: isWide ? 32 : 26,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(sublabel!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}
