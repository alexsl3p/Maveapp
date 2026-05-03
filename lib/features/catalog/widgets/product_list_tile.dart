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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.price(product.uvpPrice),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accentBrown,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.category,
                      style: AppTypography.overline,
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

