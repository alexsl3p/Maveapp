import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/app_provider.dart';
import '../../data/models/product.dart';
import '../../data/models/seller.dart';
import '../../widgets/app_button.dart';
import 'widgets/product_list_tile.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CatalogView();
  }
}

class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                AppStrings.catalogTitle,
                style: AppTypography.displayMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.lightCream,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTypography.labelLarge.copyWith(fontSize: 13),
                  unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                  labelColor: AppColors.deepText,
                  unselectedLabelColor: AppColors.mutedText,
                  tabs: const [
                    Tab(text: 'Товары'),
                    Tab(text: 'Продавцы'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ProductsTab(),
                  _SellersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        if (catalog.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
            ),
          );
        }

        if (catalog.products.isEmpty) {
          return Center(
            child: Text(
              'Нет товаров',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.mutedText),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: catalog.products.length,
          itemBuilder: (context, index) {
            final product = catalog.products[index];
            return ProductListTile(
              product: product,
              onTap: () => _showEditSheet(context, product),
              onToggleActive: (value) =>
                  catalog.toggleActive(product.id!, value),
            );
          },
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CatalogProvider>(),
        child: _ProductEditSheet(product: product),
      ),
    );
  }
}

class _SellersTab extends StatelessWidget {
  const _SellersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: app.sellers.length,
                itemBuilder: (context, index) {
                  final seller = app.sellers[index];
                  return _SellerTile(
                    seller: seller,
                    onToggle: (v) =>
                        app.toggleSellerActive(seller.id!, v),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: AppPrimaryButton(
                label: AppStrings.addSeller,
                onPressed: () => _showAddSellerSheet(context, app),
                icon: Icons.person_add_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddSellerSheet(BuildContext context, AppProvider app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _AddSellerSheet(
        onAdd: (name, code) => app.addSeller(name, code),
      ),
    );
  }
}

class _SellerTile extends StatelessWidget {
  final Seller seller;
  final ValueChanged<bool> onToggle;

  const _SellerTile({required this.seller, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            decoration: BoxDecoration(
              color: seller.isActive
                  ? AppColors.accentBrown
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                seller.initials,
                style: AppTypography.labelLarge.copyWith(
                  color: seller.isActive
                      ? AppColors.lightCream
                      : AppColors.mutedText,
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
                Text(seller.name, style: AppTypography.titleSmall),
                Text(
                  seller.isActive ? AppStrings.active : AppStrings.inactive,
                  style: AppTypography.bodySmall.copyWith(
                    color: seller.isActive
                        ? AppColors.success
                        : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: seller.isActive,
            onChanged: onToggle,
            activeColor: AppColors.accentBrown,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _AddSellerSheet extends StatefulWidget {
  final Future<void> Function(String name, String code) onAdd;

  const _AddSellerSheet({required this.onAdd});

  @override
  State<_AddSellerSheet> createState() => _AddSellerSheetState();
}

class _AddSellerSheetState extends State<_AddSellerSheet> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateCode(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'XX';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
            const SizedBox(height: 20),
            Text(AppStrings.addSeller, style: AppTypography.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Имя Фамилия',
              ),
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: AppStrings.save,
              isLoading: _isSaving,
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                setState(() => _isSaving = true);
                await widget.onAdd(name, _generateCode(name));
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductEditSheet extends StatefulWidget {
  final Product product;

  const _ProductEditSheet({required this.product});

  @override
  State<_ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends State<_ProductEditSheet> {
  late final TextEditingController _uvpController;
  late final TextEditingController _p1Controller;
  late final TextEditingController _p5Controller;
  late final TextEditingController _p10Controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _uvpController =
        TextEditingController(text: widget.product.uvpPrice.toStringAsFixed(2));
    _p1Controller = TextEditingController(
        text: widget.product.purchasePrice1.toStringAsFixed(2));
    _p5Controller = TextEditingController(
        text: widget.product.purchasePrice5.toStringAsFixed(2));
    _p10Controller = TextEditingController(
        text: widget.product.purchasePrice10.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _uvpController.dispose();
    _p1Controller.dispose();
    _p5Controller.dispose();
    _p10Controller.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c, double fallback) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              Text(AppStrings.editProduct, style: AppTypography.titleMedium),
              const SizedBox(height: 6),
              Text(
                widget.product.title,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 20),
              _PriceField(
                label: 'UVP цена',
                controller: _uvpController,
              ),
              const SizedBox(height: 12),
              _PriceField(
                label: 'Закупка 1 шт',
                controller: _p1Controller,
              ),
              const SizedBox(height: 12),
              _PriceField(
                label: 'Закупка 5 шт',
                controller: _p5Controller,
              ),
              const SizedBox(height: 12),
              _PriceField(
                label: 'Закупка 10 шт',
                controller: _p10Controller,
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: AppStrings.save,
                isLoading: _isSaving,
                onPressed: () async {
                  setState(() => _isSaving = true);
                  final updated = widget.product.copyWith(
                    uvpPrice: _parse(_uvpController, widget.product.uvpPrice),
                    purchasePrice1:
                        _parse(_p1Controller, widget.product.purchasePrice1),
                    purchasePrice5:
                        _parse(_p5Controller, widget.product.purchasePrice5),
                    purchasePrice10:
                        _parse(_p10Controller, widget.product.purchasePrice10),
                  );
                  await context
                      .read<CatalogProvider>()
                      .updateProduct(updated);
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _PriceField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: AppTypography.bodyMedium),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            style: AppTypography.titleSmall,
            decoration: const InputDecoration(
              prefixText: '€ ',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
