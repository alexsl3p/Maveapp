import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../widgets/product_image_widget.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleActive;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: product.isActive ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
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
              ProductImageWidget(
                imageUrl: product.imageUrl,
                category: product.category,
                title: product.title,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: AppTypography.overline,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _PricePill(
                          label: '1',
                          price: product.purchasePrice1,
                        ),
                        const SizedBox(width: 4),
                        _PricePill(
                          label: '5',
                          price: product.purchasePrice5,
                        ),
                        const SizedBox(width: 4),
                        _PricePill(
                          label: '10',
                          price: product.purchasePrice10,
                        ),
                        const Spacer(),
                        Text(
                          'UVP ${AppFormatters.price(product.uvpPrice)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accentBrown,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: product.isActive,
                onChanged: onToggleActive,
                activeColor: AppColors.accentBrown,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.lightCream;
                  }
                  return AppColors.mutedText;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final double price;

  const _PricePill({required this.label, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${label}×${AppFormatters.price(price)}',
        style: AppTypography.overline.copyWith(fontSize: 9),
      ),
    );
  }
}
