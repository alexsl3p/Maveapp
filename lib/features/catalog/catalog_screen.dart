import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../data/models/product.dart';
import '../../data/models/seller.dart';
import '../../services/backup_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/product_image_widget.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<AppProvider>()),
          ChangeNotifierProvider.value(value: context.read<SalesProvider>()),
          ChangeNotifierProvider.value(value: context.read<HistoryProvider>()),
          ChangeNotifierProvider.value(
              value: context.read<AnalyticsProvider>()),
          ChangeNotifierProvider.value(
              value: context.read<CatalogProvider>()),
          ChangeNotifierProvider.value(
              value: context.read<WarehouseProvider>()),
        ],
        child: const _BackupSheet(),
      ),
    );
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
              child: Row(
                children: [
                  Text(
                    AppStrings.catalogTitle,
                    style: AppTypography.displayMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSettingsSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ],
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
                    Tab(text: 'Склад'),
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
                  _WarehouseTab(),
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

// ─── Products Tab ────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  bool _reorderMode = false;

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

        if (_reorderMode) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'Удерживайте и перетащите',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedText),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _reorderMode = false),
                      child: Text(
                        'Готово',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.accentBrown),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  buildDefaultDragHandles: false,
                  itemCount: catalog.products.length,
                  itemBuilder: (context, index) {
                    final product = catalog.products[index];
                    return Row(
                      key: ValueKey(product.id),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 16),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: AppColors.mutedText,
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ProductListTile(product: product),
                        ),
                      ],
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    catalog.reorderProducts(oldIndex, newIndex);
                  },
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          itemCount: catalog.products.length + 1,
          itemBuilder: (context, index) {
            if (index == catalog.products.length) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: AppPrimaryButton(
                  label: AppStrings.addProduct,
                  onPressed: () => _showAddSheet(context, catalog),
                  icon: Icons.add,
                ),
              );
            }
            final product = catalog.products[index];
            return GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                setState(() => _reorderMode = true);
              },
              child: ProductListTile(
                product: product,
                onTap: () => _showEditSheet(context, product, catalog),
                onToggleActive: (value) =>
                    catalog.toggleActive(product.id!, value),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSheet(
      BuildContext context, Product product, CatalogProvider catalog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: catalog,
        child: _ProductEditSheet(product: product),
      ),
    );
  }

  void _showAddSheet(BuildContext context, CatalogProvider catalog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: catalog,
        child: const _ProductAddSheet(),
      ),
    );
  }
}

// ─── Warehouse Tab ────────────────────────────────────────────────────────────

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<CatalogProvider, WarehouseProvider>(
      builder: (context, catalog, warehouse, _) {
        if (catalog.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
            ),
          );
        }

        final products = catalog.products.where((p) => p.isActive).toList();

        if (products.isEmpty) {
          return Center(
            child: Text(
              'Нет активных товаров',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText),
            ),
          );
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.of(context).padding.bottom + 80,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final stockMap = warehouse.stockByLocation(product.id!);
            final homeStock = stockMap['home'] ?? 0;
            return _WarehouseProductTile(
              product: product,
              stockMap: stockMap,
              onTap: () => _showAddStockSheet(context, product, warehouse),
              onTransfer: homeStock > 0
                  ? () => _showTransferDialog(
                      context, product, warehouse, homeStock)
                  : null,
            );
          },
        );
      },
    );
  }

  void _showAddStockSheet(
    BuildContext context,
    Product product,
    WarehouseProvider warehouse,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: warehouse,
        child: _AddStockSheet(product: product),
      ),
    );
  }

  void _showTransferDialog(
    BuildContext context,
    Product product,
    WarehouseProvider warehouse,
    int homeStock,
  ) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: warehouse,
        child: _TransferDialog(product: product, maxQty: homeStock),
      ),
    );
  }
}

class _WarehouseProductTile extends StatelessWidget {
  final Product product;
  final Map<String, int> stockMap;
  final VoidCallback onTap;
  final VoidCallback? onTransfer;

  const _WarehouseProductTile({
    required this.product,
    required this.stockMap,
    required this.onTap,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    final homeStock = stockMap['home'] ?? 0;
    final salonStock = stockMap['salon'] ?? 0;
    final totalStock = homeStock + salonStock;

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
          ProductImageWidget(
            imageUrl: product.imageUrl,
            category: product.category,
            title: product.title,
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: AppTypography.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (homeStock > 0) ...[
                      const Icon(Icons.home_outlined,
                          size: 11, color: AppColors.mutedText),
                      const SizedBox(width: 2),
                      Text('$homeStock',
                          style: AppTypography.overline
                              .copyWith(fontSize: 10)),
                      const SizedBox(width: 8),
                    ],
                    if (salonStock > 0) ...[
                      const Icon(Icons.storefront_outlined,
                          size: 11, color: AppColors.accentBrown),
                      const SizedBox(width: 2),
                      Text('$salonStock',
                          style: AppTypography.overline.copyWith(
                              fontSize: 10,
                              color: AppColors.accentBrown)),
                    ],
                    if (totalStock == 0)
                      Text('нет на складе',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.mutedText)),
                  ],
                ),
              ],
            ),
          ),
          // Transfer home → salon button
          if (onTransfer != null)
            GestureDetector(
              onTap: onTransfer,
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.accentBrown,
                  size: 16,
                ),
              ),
            ),
          // Add stock button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBrown,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.lightCream,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStockSheet extends StatefulWidget {
  final Product product;

  const _AddStockSheet({required this.product});

  @override
  State<_AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends State<_AddStockSheet> {
  int _tier = 1;
  String _location = 'home';
  final _quantityController = TextEditingController(text: '1');
  late TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product.purchasePrice1.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onTierChanged(int tier) {
    setState(() {
      _tier = tier;
      _priceController.text =
          widget.product.purchasePriceForTier(tier).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.viewInsets.bottom + mq.viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
              Text('Добавить на склад', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              Text(
                widget.product.title,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.mutedText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Text('Склад', style: AppTypography.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: ['home', 'salon'].map((loc) {
                  final isSelected = _location == loc;
                  final label = loc == 'salon' ? 'Салон' : 'Дом';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: loc == 'home' ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _location = loc),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                          child: Center(
                            child: Text(
                              label,
                              style: AppTypography.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.lightCream
                                    : AppColors.deepText,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Закупочная цена', style: AppTypography.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [1, 5, 10, if (widget.product.hasBoxPrice) 25].map((tier) {
                  final tiers = [1, 5, 10, if (widget.product.hasBoxPrice) 25];
                  final isSelected = _tier == tier;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: tier != tiers.last ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => _onTierChanged(tier),
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
                                AppFormatters.price(
                                    widget.product.purchasePriceForTier(tier)),
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
              const SizedBox(height: 16),
              _PriceField(
                label: 'Цена закупки',
                controller: _priceController,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text('Количество', style: AppTypography.bodyMedium),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: AppTypography.titleSmall,
                      decoration: const InputDecoration(
                        suffixText: ' шт',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: 'Добавить',
                isLoading: _isSaving,
                onPressed: () async {
                  final qty = int.tryParse(_quantityController.text) ?? 0;
                  if (qty <= 0) return;
                  final price = double.tryParse(
                          _priceController.text.replaceAll(',', '.')) ??
                      widget.product.purchasePriceForTier(_tier);
                  setState(() => _isSaving = true);
                  await context
                      .read<WarehouseProvider>()
                      .addStock(widget.product.id!, qty, _tier, price, _location);
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

// ─── Sellers Tab ─────────────────────────────────────────────────────────────

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
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
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
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.viewInsets.bottom + mq.viewPadding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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

// ─── Product Edit Sheet ───────────────────────────────────────────────────────

class _ProductEditSheet extends StatefulWidget {
  final Product product;

  const _ProductEditSheet({required this.product});

  @override
  State<_ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends State<_ProductEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _uvpController;
  late final TextEditingController _p1Controller;
  late final TextEditingController _p5Controller;
  late final TextEditingController _p10Controller;
  late final TextEditingController _pBoxController;
  bool _isSaving = false;
  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _uvpController =
        TextEditingController(text: widget.product.uvpPrice.toStringAsFixed(2));
    _p1Controller = TextEditingController(
        text: widget.product.purchasePrice1.toStringAsFixed(2));
    _p5Controller = TextEditingController(
        text: widget.product.purchasePrice5.toStringAsFixed(2));
    _p10Controller = TextEditingController(
        text: widget.product.purchasePrice10.toStringAsFixed(2));
    _pBoxController = TextEditingController(
        text: widget.product.purchasePriceBox > 0
            ? widget.product.purchasePriceBox.toStringAsFixed(2)
            : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _uvpController.dispose();
    _p1Controller.dispose();
    _p5Controller.dispose();
    _p10Controller.dispose();
    _pBoxController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c, double fallback) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? fallback;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file != null && mounted) {
      final permanent = await _copyToDocuments(file.path);
      setState(() => _newImagePath = permanent);
    }
  }

  Future<String> _copyToDocuments(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = '${dir.path}/$name';
    await File(tempPath).copy(dest);
    return dest;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.viewInsets.bottom + mq.viewPadding.bottom;
    final currentImageUrl = _newImagePath ?? widget.product.imageUrl;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyLarge,
                decoration: const InputDecoration(hintText: 'Название товара'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (currentImageUrl != null &&
                            currentImageUrl.isNotEmpty)
                          _newImagePath != null
                              ? Image.file(
                                  File(_newImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : ProductImageWidget(
                                  imageUrl: currentImageUrl,
                                  category: widget.product.category,
                                  title: widget.product.title,
                                  height: 120,
                                )
                        else
                          ProductImageWidget(
                            imageUrl: null,
                            category: widget.product.category,
                            title: widget.product.title,
                            height: 120,
                          ),
                        Container(
                          color: Colors.black.withOpacity(0.25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_outlined,
                                  color: Colors.white, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                currentImageUrl != null
                                    ? 'Изменить фото'
                                    : 'Добавить фото',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _PriceField(
                label: 'Цена продажи',
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
              const SizedBox(height: 12),
              _PriceField(
                label: 'Закупка коробка',
                controller: _pBoxController,
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: AppStrings.save,
                isLoading: _isSaving,
                onPressed: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  setState(() => _isSaving = true);
                  final updated = widget.product.copyWith(
                    title: title,
                    uvpPrice: _parse(_uvpController, widget.product.uvpPrice),
                    purchasePrice1:
                        _parse(_p1Controller, widget.product.purchasePrice1),
                    purchasePrice5:
                        _parse(_p5Controller, widget.product.purchasePrice5),
                    purchasePrice10:
                        _parse(_p10Controller, widget.product.purchasePrice10),
                    purchasePriceBox:
                        _parse(_pBoxController, widget.product.purchasePriceBox),
                    imageUrl: _newImagePath ?? widget.product.imageUrl,
                  );
                  await context.read<CatalogProvider>().updateProduct(updated);
                  if (mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.lightCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text('Удалить товар?',
                            style: AppTypography.titleMedium),
                        content: Text(
                          'Товар будет удалён из каталога. История продаж сохранится.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.mutedText),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Отмена'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'Удалить',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      await context
                          .read<CatalogProvider>()
                          .deleteProduct(widget.product.id!);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Удалить товар',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Product Add Sheet ────────────────────────────────────────────────────────

class _ProductAddSheet extends StatefulWidget {
  const _ProductAddSheet();

  @override
  State<_ProductAddSheet> createState() => _ProductAddSheetState();
}

class _ProductAddSheetState extends State<_ProductAddSheet> {
  final _titleController = TextEditingController();
  final _uvpController = TextEditingController();
  final _p1Controller = TextEditingController();
  final _p5Controller = TextEditingController();
  final _p10Controller = TextEditingController();
  final _pBoxController = TextEditingController();
  String _category = 'KOSMETIK';
  String? _imagePath;
  bool _isSaving = false;

  static const _categories = [
    'KOSMETIK',
    'KÖRPER',
    'INSTRUMENT',
    'PROFESSIONAL',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _uvpController.dispose();
    _p1Controller.dispose();
    _p5Controller.dispose();
    _p10Controller.dispose();
    _pBoxController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file != null && mounted) {
      final permanent = await _copyToDocuments(file.path);
      setState(() => _imagePath = permanent);
    }
  }

  Future<String> _copyToDocuments(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = '${dir.path}/$name';
    await File(tempPath).copy(dest);
    return dest;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.viewInsets.bottom + mq.viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
              Text(AppStrings.addProduct, style: AppTypography.titleMedium),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_imagePath != null)
                          Image.file(File(_imagePath!), fit: BoxFit.cover)
                        else
                          Container(color: AppColors.surface),
                        Container(
                          color: Colors.black
                              .withOpacity(_imagePath != null ? 0.25 : 0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: _imagePath != null
                                    ? Colors.white
                                    : AppColors.mutedText,
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _imagePath != null
                                    ? 'Изменить фото'
                                    : 'Добавить фото',
                                style: AppTypography.labelLarge.copyWith(
                                  color: _imagePath != null
                                      ? Colors.white
                                      : AppColors.mutedText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyLarge,
                decoration: const InputDecoration(hintText: 'Название товара'),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    style: AppTypography.bodyMedium,
                    dropdownColor: AppColors.lightCream,
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PriceField(label: 'Цена продажи', controller: _uvpController),
              const SizedBox(height: 12),
              _PriceField(label: 'Закупка 1 шт', controller: _p1Controller),
              const SizedBox(height: 12),
              _PriceField(label: 'Закупка 5 шт', controller: _p5Controller),
              const SizedBox(height: 12),
              _PriceField(label: 'Закупка 10 шт', controller: _p10Controller),
              const SizedBox(height: 12),
              _PriceField(label: 'Закупка коробка', controller: _pBoxController),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: AppStrings.save,
                isLoading: _isSaving,
                onPressed: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  setState(() => _isSaving = true);
                  final product = Product(
                    title: title,
                    category: _category,
                    imageUrl: _imagePath,
                    uvpPrice: _parse(_uvpController),
                    purchasePrice1: _parse(_p1Controller),
                    purchasePrice5: _parse(_p5Controller),
                    purchasePrice10: _parse(_p10Controller),
                    purchasePriceBox: _parse(_pBoxController),
                  );
                  await context.read<CatalogProvider>().addProduct(product);
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

// ─── Transfer Dialog ──────────────────────────────────────────────────────────

class _TransferDialog extends StatefulWidget {
  final Product product;
  final int maxQty;

  const _TransferDialog({required this.product, required this.maxQty});

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _qtyController = TextEditingController(text: '1');
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.lightCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.arrow_forward_rounded,
              color: AppColors.accentBrown, size: 20),
          const SizedBox(width: 8),
          Text('В салон', style: AppTypography.titleSmall),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.title,
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Дом → Салон · макс. ${widget.maxQty} шт',
            style: AppTypography.overline.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTypography.bodyLarge,
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'шт',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена',
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.mutedText)),
        ),
        TextButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final qty = int.tryParse(_qtyController.text) ?? 0;
                  if (qty <= 0 || qty > widget.maxQty) return;
                  final warehouse = context.read<WarehouseProvider>();
                  setState(() => _isSaving = true);
                  await warehouse.transfer(widget.product.id!, qty);
                  if (mounted) Navigator.pop(context);
                },
          child: Text(
            _isSaving ? '...' : 'Перевести',
            style: AppTypography.labelLarge
                .copyWith(color: AppColors.accentBrown),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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

// ─── Backup / Settings Sheet ──────────────────────────────────────────────────

class _BackupSheet extends StatefulWidget {
  const _BackupSheet();

  @override
  State<_BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<_BackupSheet> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    await BackupService.exportBackup(context);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightCream,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            Text('Восстановить данные?', style: AppTypography.titleMedium),
        content: Text(
          'Все текущие данные будут заменены данными из файла резервной копии. Это действие необратимо.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Восстановить',
                style:
                    AppTypography.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final ok = await BackupService.importBackup(context);
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      // Reload all providers with fresh data.
      await Future.wait([
        context.read<AppProvider>().init(),
        context.read<SalesProvider>().init(),
        context.read<HistoryProvider>().load(),
        context.read<AnalyticsProvider>().load(),
        context.read<CatalogProvider>().load(),
        context.read<WarehouseProvider>().load(),
      ]);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные восстановлены')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, mq.viewPadding.bottom + 20),
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
          Text('Резервная копия', style: AppTypography.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Все данные: товары, продажи, склад, продавцы.',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 20),
          _ActionTile(
            icon: Icons.upload_outlined,
            iconColor: AppColors.accentBrown,
            title: 'Создать резервную копию',
            subtitle: 'Сохранить файл .db через Поделиться',
            onTap: _busy ? null : _export,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.download_outlined,
            iconColor: AppColors.success,
            title: 'Восстановить из копии',
            subtitle: 'Выбрать файл .db с этого устройства',
            onTap: _busy ? null : _import,
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentBrown),
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.mutedText)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.divider, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
