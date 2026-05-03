import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../providers/sales_provider.dart';
import '../../data/models/product.dart';
import '../../data/models/seller.dart';
import '../../core/utils/formatters.dart';
import 'widgets/product_card.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/sale_bottom_sheet.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SalesView();
  }
}

class _SalesView extends StatelessWidget {
  const _SalesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer2<AppProvider, SalesProvider>(
          builder: (context, app, sales, _) {
            if (app.isLoading || sales.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, app, sales),
                _buildSummaryCard(sales),
                _buildSearchAndFilter(context, sales),
                _buildProductGrid(context, sales),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAppBar(
    BuildContext context,
    AppProvider app,
    SalesProvider sales,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/mave_logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            _SellerSelector(
              sellers: app.sellers,
              selected: app.currentSeller,
              onSelected: app.setCurrentSeller,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSummaryCard(SalesProvider sales) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 4),
        child: MonthlySummaryCard(
          monthlyProfit: sales.monthlyProfit,
          salesCount: sales.monthlySalesCount,
          monthKey: AppFormatters.toMonthKey(DateTime.now()),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchAndFilter(
      BuildContext context, SalesProvider sales) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: sales.setSearch,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.mutedText,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          if (sales.categories.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sales.categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _CategoryChip(
                      label: AppStrings.allCategories,
                      isSelected: sales.selectedCategory == null,
                      onTap: () => sales.setCategory(null),
                    );
                  }
                  final cat = sales.categories[i - 1];
                  return _CategoryChip(
                    label: cat,
                    isSelected: sales.selectedCategory == cat,
                    onTap: () => sales.setCategory(cat),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, SalesProvider sales) {
    if (sales.products.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.mutedText.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text(AppStrings.noProducts, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = sales.products[index];
            return ProductCard(
              product: product,
              onTap: () => _openSaleSheet(context, product),
            );
          },
          childCount: sales.products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
      ),
    );
  }

  void _openSaleSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: ChangeNotifierProvider.value(
          value: context.read<SalesProvider>(),
          child: SaleBottomSheet(product: product),
        ),
      ),
    );
  }
}

class _SellerSelector extends StatelessWidget {
  final List<Seller> sellers;
  final Seller? selected;
  final ValueChanged<Seller> onSelected;

  const _SellerSelector({
    required this.sellers,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showSellerPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SellerAvatar(name: selected?.name ?? '?', size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Продавец',
                  style: AppTypography.overline.copyWith(fontSize: 9),
                ),
                Text(
                  selected?.name.split(' ').first ?? AppStrings.selectSeller,
                  style: AppTypography.labelLarge.copyWith(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }

  void _showSellerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 16, 20,
          MediaQuery.of(ctx).viewPadding.bottom + 16,
        ),
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
            Text('Выберите продавца', style: AppTypography.titleMedium),
            const SizedBox(height: 16),
            ...sellers.map(
              (seller) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _SellerAvatar(name: seller.name, size: 40),
                title: Text(seller.name, style: AppTypography.titleSmall),
                trailing: selected?.id == seller.id
                    ? const Icon(Icons.check, color: AppColors.accentBrown)
                    : null,
                onTap: () {
                  onSelected(seller);
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

class _SellerAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _SellerAvatar({required this.name, required this.size});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentBrown,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.lightCream,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
