import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/sale.dart';

class SaleListItem extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onCancel;

  const SaleListItem({
    super.key,
    required this.sale,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = !sale.isActive;

    return Opacity(
      opacity: isCancelled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: isCancelled
              ? Border.all(color: AppColors.divider, width: 0.5)
              : null,
          boxShadow: isCancelled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Category color dot
            _CategoryDot(category: sale.productTitleSnapshot),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.productTitleSnapshot,
                    style: AppTypography.titleSmall.copyWith(
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        sale.sellerNameSnapshot.split(' ').first,
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.mutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${sale.quantity} шт · ${sale.purchaseTier} уп.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.mutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppFormatters.dayMonth(sale.soldAt),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Price + profit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.price(sale.salePriceSnapshot * sale.quantity),
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: sale.profit >= 0
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppFormatters.price(sale.profit),
                        style: AppTypography.bodySmall.copyWith(
                          color: sale.profit >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.percent(sale.margin),
                  style: AppTypography.overline.copyWith(fontSize: 10),
                ),
              ],
            ),
            if (!isCancelled && onCancel != null)
              GestureDetector(
                onTap: () => _confirmCancel(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.mutedText.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Отменить продажу?',
          style: AppTypography.titleMedium,
        ),
        content: Text(
          'Продажа будет помечена как отменённая. История сохранится.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Нет'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onCancel?.call();
            },
            child: Text(
              'Да, отменить',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDot extends StatelessWidget {
  final String category;

  const _CategoryDot({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          size: 20,
          color: AppColors.accentBrown.withOpacity(0.7),
        ),
      ),
    );
  }
}
