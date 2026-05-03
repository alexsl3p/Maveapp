import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/product.dart';
import '../../../data/models/sale.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/sales_provider.dart';
import '../../../widgets/product_image_widget.dart';
import '../../../widgets/app_button.dart';

class SaleBottomSheet extends StatefulWidget {
  final Product product;

  const SaleBottomSheet({super.key, required this.product});

  @override
  State<SaleBottomSheet> createState() => _SaleBottomSheetState();
}

class _SaleBottomSheetState extends State<SaleBottomSheet>
    with SingleTickerProviderStateMixin {
  int _selectedTier = 1;
  int _quantity = 1;
  late final TextEditingController _priceController;
  bool _isSaving = false;
  bool _showSuccess = false;

  late AnimationController _successController;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product.uvpPrice.toStringAsFixed(2),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _successController.dispose();
    super.dispose();
  }

  double get _purchasePrice =>
      widget.product.purchasePriceForTier(_selectedTier);

  double get _salePrice =>
      double.tryParse(_priceController.text.replaceAll(',', '.')) ??
      widget.product.uvpPrice;

  double get _unitProfit => _salePrice - _purchasePrice;
  double get _totalProfit => _unitProfit * _quantity;
  double get _margin => _salePrice > 0 ? (_unitProfit / _salePrice) * 100 : 0;
  double get _revenue => _salePrice * _quantity;

  Future<void> _saveSale() async {
    if (_isSaving) return;
    final appProvider = context.read<AppProvider>();
    final seller = appProvider.currentSeller;
    if (seller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите продавца')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final isUvp =
        (_salePrice - widget.product.uvpPrice).abs() < 0.001;

    final sale = Sale(
      productId: widget.product.id!,
      sellerId: seller.id!,
      productTitleSnapshot: widget.product.title,
      sellerNameSnapshot: seller.name,
      purchasePriceSnapshot: _purchasePrice,
      salePriceSnapshot: _salePrice,
      priceMode: isUvp ? 'uvp' : 'custom',
      purchaseTier: _selectedTier,
      quantity: _quantity,
      profit: _totalProfit,
      margin: _margin,
      soldAt: now,
      monthKey: AppFormatters.toMonthKey(now),
    );

    await context.read<SalesProvider>().saveSale(sale);

    HapticFeedback.heavyImpact();
    setState(() {
      _isSaving = false;
      _showSuccess = true;
    });
    _successController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccess(context);

    final mq = MediaQuery.of(context);
    final bottomPadding = mq.viewInsets.bottom + mq.viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildProductHeader(),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTierSelector(),
                  const SizedBox(height: 20),
                  _buildPriceSection(),
                  const SizedBox(height: 20),
                  _buildQuantitySelector(),
                  const SizedBox(height: 20),
                  _buildProfitPreview(),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    label: AppStrings.saveSale,
                    onPressed: _saveSale,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          ProductImageWidget(
            imageUrl: widget.product.imageUrl,
            category: widget.product.category,
            title: widget.product.title,
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.category, style: AppTypography.overline),
                const SizedBox(height: 4),
                Text(
                  widget.product.title,
                  style: AppTypography.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Закупочная цена', style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: [1, 5, 10].map((tier) {
            final isSelected = _selectedTier == tier;
            final price = widget.product.purchasePriceForTier(tier);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: tier != 10 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTier = tier);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentBrown
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.divider, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.product.tierLabel(tier),
                          style: AppTypography.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.lightCream
                                : AppColors.deepText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppFormatters.price(price),
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.lightCream.withOpacity(0.8)
                                : AppColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.salePrice, style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Text(
                  '€',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: AppColors.mutedText,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    color: AppColors.deepText,
                    letterSpacing: -2,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            _priceController.text =
                widget.product.uvpPrice.toStringAsFixed(2);
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'UVP ${AppFormatters.price(widget.product.uvpPrice)}  ↩',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.accentBrown,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quantity, style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            _QtyButton(
              icon: Icons.remove,
              onTap:
                  _quantity > 1 ? () => setState(() => _quantity--) : null,
            ),
            const SizedBox(width: 16),
            Text(
              '$_quantity',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 16),
            _QtyButton(
              icon: Icons.add,
              onTap: () => setState(() => _quantity++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PreviewMetric(
              label: AppStrings.revenuePreview,
              value: AppFormatters.price(_revenue),
            ),
          ),
          Container(
              width: 0.5,
              height: 36,
              color: AppColors.success.withOpacity(0.25)),
          Expanded(
            child: _PreviewMetric(
              label: AppStrings.purchaseCost,
              value: AppFormatters.price(_purchasePrice * _quantity),
            ),
          ),
          Container(
              width: 0.5,
              height: 36,
              color: AppColors.success.withOpacity(0.25)),
          Expanded(
            child: _PreviewMetric(
              label: AppStrings.profitPreview,
              value: AppFormatters.price(_totalProfit),
              valueColor:
                  _totalProfit >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: 260 + mq.viewPadding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _successOpacity,
          child: ScaleTransition(
            scale: _successScale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.saleSaved,
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.success),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.price(_totalProfit),
                  style: AppTypography.kpiValue
                      .copyWith(color: AppColors.success),
                ),
                Text('прибыль', style: AppTypography.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.divider,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.deepText : AppColors.mutedText,
          size: 20,
        ),
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PreviewMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.overline.copyWith(fontSize: 9),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: valueColor ?? AppColors.deepText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
