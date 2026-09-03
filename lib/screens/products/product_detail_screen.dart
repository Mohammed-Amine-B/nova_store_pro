import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_status.dart';
import '../../data/repositories/insights_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/crop_image_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/money_text.dart';
import '../../widgets/design/design_card.dart';
import '../../widgets/design/kpi_card.dart';
import '../../widgets/design/dashed_border_box.dart';
import '../../widgets/enter_to_submit.dart';
import '../../utils/formatting.dart';
import '../../utils/product_images.dart';
import 'product_form_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final AppDatabase db;
  final int productId;
  const ProductDetailScreen({
    super.key,
    required this.db,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductRepository _repo = ProductRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);

  List<Category> _categories = [];

  Product? _product;
  List<ProductBatche> _batches = [];
  List<StockMovement> _movements = [];
  List<Product> _variants = [];
  String _categoryName = '—';
  double _dailyVelocity = 0; // units/day sold over the last 30 days
  List<({String supplierName, double avgBuyPrice, int purchaseCount})>
  _supplierPrices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final product = await _repo.getById(widget.productId);
    final batches = await _repo.getBatches(widget.productId);
    final movements = await _repo.getMovements(widget.productId);
    final categoriesWithCounts = await _categoryRepo.getAllWithCounts();
    final categories = categoriesWithCounts.map((c) => c.category).toList();
    final variants = product != null
        ? await _repo.getVariants(product.name, excludeId: product.id)
        : <Product>[];
    final dailyVelocity = await _computeDailyVelocity();
    final supplierPrices = await _repo.getSupplierPriceComparison(
      widget.productId,
    );

    String categoryName = '—';
    if (product?.categoryId != null) {
      categoryName = categories
          .firstWhere(
            (c) => c.id == product!.categoryId,
            orElse: () =>
                Category(id: -1, name: '—', createdAt: DateTime.now()),
          )
          .name;
    }

    if (!mounted) return;
    setState(() {
      _product = product;
      _batches = batches;
      _movements = movements;
      _variants = variants;
      _categoryName = categoryName;
      _categories = categories;
      _dailyVelocity = dailyVelocity;
      _supplierPrices = supplierPrices;
      _loading = false;
    });
  }

  /// Units/day sold over the last 30 days, same calculation the
  /// reorder-suggestion insight uses (InsightsRepository.getReorderSuggestions),
  /// scoped to just this product. Read-only — no writes, no schema changes.
  Future<double> _computeDailyVelocity() async {
    final db = _repo.db;
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 30));
    final recentSales = await (db.select(
      db.sales,
    )..where((s) => s.date.isBiggerOrEqualValue(start))).get();
    final saleIds = recentSales.map((s) => s.id).toSet();
    if (saleIds.isEmpty) return 0;
    final items =
        await (db.select(db.saleItems)..where(
              (i) =>
                  i.saleId.isIn(saleIds) & i.productId.equals(widget.productId),
            ))
            .get();
    final totalSold = items.fold<double>(0, (sum, i) => sum + i.quantity);
    return totalSold / 30;
  }

  Future<void> _openVariant(Product variant) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailScreen(db: widget.db, productId: variant.id),
      ),
    );
    _load();
  }

  Future<void> _editProduct() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(
        repo: _repo,
        categories: _categories,
        editing: _product,
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _deleteProduct() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.removeProductTitle,
      message: l10n.removeProductMessage(_product!.name),
      confirmLabel: l10n.removeAction,
      tone: ConfirmTone.destructive,
      icon: Icons.archive_outlined,
    );
    if (confirmed) {
      await _repo.archive(_product!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _restoreProduct() async {
    await _repo.unarchive(_product!.id);
    _load();
  }

  Future<void> _changePhoto() async {
    final picked = await FilePicker.pickFile(type: FileType.image);
    final pickedPath = picked?.path;
    if (pickedPath == null) return;
    final bytes = await File(pickedPath).readAsBytes();
    if (!mounted) return;
    final cropped = await showCropImageDialog(context, bytes);
    if (cropped == null) return;
    final filename = await saveProductImageBytes(cropped);
    await _repo.updateImage(_product!.id, filename);
    _load();
  }

  Future<void> _removePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.removePhotoTitle,
      message: l10n.removePhotoMessage,
      confirmLabel: l10n.removeAction,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_outline,
    );
    if (confirmed) {
      await _repo.updateImage(_product!.id, null);
      _load();
    }
  }

  Future<void> _openAddStock() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => _AddStockDialog(repo: _repo, product: _product!),
    );
    if (added == true) _load();
  }

  void _openMovements() {
    showDialog(
      context: context,
      builder: (context) => _MovementsDialog(repo: _repo, product: _product!),
    );
  }

  // Barcode-label printing doesn't exist yet as a feature in this app — this
  // button is wired to a "coming soon" notice rather than left disabled, per
  // the redesign brief's own judgment call, so it doesn't look broken.
  void _showBarcodePrintComingSoon() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.barcodePrintComingSoon)));
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _unitLabel(AppLocalizations l10n, String unitType) =>
      switch (unitType) {
        'kg' => l10n.unitTypeKg,
        'meter' => l10n.unitTypeMeter,
        _ => l10n.unitTypePiece,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.productDetailFallbackTitle)),
        body: Center(child: Text(l10n.productNoLongerExists)),
      );
    }

    final theme = Theme.of(context);
    final costPrice = _batches.isNotEmpty ? _batches.last.buyPrice : null;
    final sellingPrice = product.sellingPrice;
    final margin = (sellingPrice != null && costPrice != null)
        ? sellingPrice - costPrice
        : null;
    final marginPercent =
        (margin != null && sellingPrice != null && sellingPrice != 0)
        ? (margin / sellingPrice * 100)
        : null;
    final stockValue = costPrice != null
        ? product.stockQuantity * costPrice
        : null;

    return Scaffold(
      backgroundColor: DesignColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, l10n, theme, product),
              const SizedBox(height: 20),
              _buildKpiRow(
                context,
                l10n,
                theme,
                product,
                costPrice,
                margin,
                marginPercent,
                stockValue,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 900;
                  final left = _buildLeftColumn(context, l10n, theme, product);
                  final right = _buildRightColumn(
                    context,
                    l10n,
                    theme,
                    product,
                  );
                  if (narrow) {
                    return Column(
                      children: [left, const SizedBox(height: 20), right],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 340, child: left),
                      const SizedBox(width: 20),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Header card
  // -------------------------------------------------------------------
  Widget _buildHeaderCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    final metaStyle = designSans(
      theme.textTheme.bodySmall,
      color: DesignColors.textMuted,
    );
    final metaMonoStyle = designMono(
      theme.textTheme.bodySmall,
      color: DesignColors.textMuted,
    );
    final hasVariant =
        product.variantSize != null && product.variantSize!.trim().isNotEmpty;

    return DesignCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButton(color: DesignColors.textPrimary),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      productDisplayName(product),
                      style: designSans(
                        theme.textTheme.headlineSmall,
                        color: DesignColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _CodePill(product.code),
                    _ActiveStatusPill(
                      isArchived: product.isArchived,
                      label: product.isArchived
                          ? l10n.statusArchived
                          : l10n.statusActive,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(_categoryName, style: metaStyle),
                    Text('•', style: metaStyle),
                    if (hasVariant) ...[
                      Text(product.variantSize!, style: metaStyle),
                      Text('•', style: metaStyle),
                    ],
                    Text(_unitLabel(l10n, product.unitType), style: metaStyle),
                    Text('•', style: metaStyle),
                    Text('#${product.id}', style: metaMonoStyle),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _openAddStock,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignColors.teal,
                ),
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: Text(
                  l10n.addStock,
                  style: designSans(
                    theme.textTheme.labelLarge,
                    color: Colors.white,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _editProduct,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.textPrimary,
                  side: const BorderSide(color: DesignColors.cardBorder),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  l10n.editProduct,
                  style: designSans(
                    theme.textTheme.labelLarge,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openMovements,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.textPrimary,
                  side: const BorderSide(color: DesignColors.cardBorder),
                ),
                icon: const Icon(Icons.history, size: 18),
                label: Text(
                  l10n.viewStockMovements,
                  style: designSans(
                    theme.textTheme.labelLarge,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
              product.isArchived
                  ? OutlinedButton.icon(
                      onPressed: _restoreProduct,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFF16A34A)),
                      ),
                      icon: const Icon(Icons.restore, size: 18),
                      label: Text(
                        l10n.restoreAction,
                        style: designSans(
                          theme.textTheme.labelLarge,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _deleteProduct,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignColors.destructiveText,
                        side: const BorderSide(
                          color: DesignColors.destructiveBorder,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        l10n.delete,
                        style: designSans(
                          theme.textTheme.labelLarge,
                          color: DesignColors.destructiveText,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // KPI row
  // -------------------------------------------------------------------
  Widget _buildKpiRow(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
    double? costPrice,
    double? margin,
    double? marginPercent,
    double? stockValue,
  ) {
    final stockDiff = product.stockQuantity - product.minStock;
    final String stockNote;
    if (stockDiff > 0) {
      stockNote = l10n.aboveMinimumNote(
        formatQuantity(stockDiff, product.unitType),
      );
    } else if (stockDiff < 0) {
      stockNote = l10n.belowMinimumNote(
        formatQuantity(-stockDiff, product.unitType),
      );
    } else {
      stockNote = l10n.atMinimumNote;
    }

    const brandTeal = Color(0xFF0E7C7B);
    const brandSaffron = Color(0xFFF2A93B);
    const brandSuccess = Color(0xFF16A34A);
    const brandTerracotta = Color(0xFFE4572E);

    return KpiRow(
      children: [
        KpiCard(
          label: l10n.currentStockLabel,
          value: formatQuantity(product.stockQuantity, product.unitType),
          note: stockNote,
          noteColor: stockDiff < 0 ? brandTerracotta : null,
          icon: Icons.inventory_2_outlined,
          badgeColor: brandTeal,
        ),
        KpiCard(
          label: l10n.sellingPriceLabel,
          value: sellingPriceText(product, l10n),
          note: l10n.perUnitNote,
          icon: Icons.sell_outlined,
          badgeColor: brandSaffron,
        ),
        KpiCard(
          label: l10n.costPriceLabel,
          value: costPrice != null ? formatMoney(costPrice) : '—',
          note: costPrice != null ? l10n.latestBatchAverageNote : null,
          icon: Icons.receipt_long_outlined,
          badgeColor: DesignColors.textMuted,
        ),
        KpiCard(
          label: l10n.profitMarginLabel,
          value: margin != null ? formatMoney(margin) : '—',
          note: marginPercent != null
              ? l10n.percentOfSellingPriceNote(marginPercent.toStringAsFixed(0))
              : null,
          noteColor: (margin != null && margin > 0) ? brandTeal : null,
          icon: Icons.trending_up,
          badgeColor: brandSuccess,
        ),
        KpiCard(
          label: l10n.statStockValue,
          value: stockValue != null ? formatMoney(stockValue) : '—',
          note: (stockValue != null && costPrice != null)
              ? l10n.stockValueFormulaNote(
                  formatQuantity(product.stockQuantity, product.unitType),
                  formatMoney(costPrice),
                )
              : null,
          hero: true,
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  String sellingPriceText(Product product, AppLocalizations l10n) =>
      product.sellingPrice != null
      ? formatMoney(product.sellingPrice!)
      : l10n.notSet;

  // -------------------------------------------------------------------
  // Left column: photo + stock status
  // -------------------------------------------------------------------
  Widget _buildLeftColumn(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhotoCard(context, l10n, theme, product),
        const SizedBox(height: 20),
        _buildStockStatusCard(context, l10n, theme, product),
        if (_supplierPrices.length >= 2) ...[
          const SizedBox(height: 20),
          _buildBestSupplierCard(context, l10n, theme),
        ],
      ],
    );
  }

  /// Only rendered when the product has been bought from 2+ suppliers — a
  /// single supplier means there's nothing to compare.
  Widget _buildBestSupplierCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    const brandTeal = Color(0xFF0E7C7B);
    final best = _supplierPrices.first;
    final others = _supplierPrices.skip(1);
    final othersList = others
        .map((s) => '${s.supplierName} (${formatMoney(s.avgBuyPrice)})')
        .join(', ');

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(l10n.bestSupplierPanel),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: brandTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  size: 16,
                  color: brandTeal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  best.supplierName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: designSans(
                    theme.textTheme.bodyMedium,
                    color: DesignColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MoneyText(
            formatMoney(best.avgBuyPrice),
            style: designMono(
              theme.textTheme.headlineSmall,
              color: brandTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.avgPriceAcrossPurchases(best.purchaseCount),
            style: designSans(
              theme.textTheme.labelSmall,
              color: DesignColors.textMuted,
            ),
          ),
          if (othersList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.alsoBoughtFromNote(othersList),
              style: designSans(
                theme.textTheme.labelSmall,
                color: DesignColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: FutureBuilder<String?>(
              future: resolveProductImagePath(product.imagePath),
              builder: (context, snapshot) {
                final resolved = snapshot.data;
                if (resolved != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(DesignRadii.inner),
                    child: Image.file(
                      File(resolved),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }
                return DashedBorderBox(
                  borderRadius: DesignRadii.inner,
                  child: SizedBox.expand(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: DesignColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noPhotoLabel,
                            style: designSans(
                              theme.textTheme.bodySmall,
                              color: DesignColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _changePhoto,
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.teal,
                side: const BorderSide(color: DesignColors.teal),
              ),
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: Text(
                l10n.changePhotoAction,
                style: designSans(
                  theme.textTheme.labelLarge,
                  color: DesignColors.teal,
                ),
              ),
            ),
          ),
          if (product.imagePath != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _removePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.destructiveText,
                  side: const BorderSide(color: DesignColors.destructiveBorder),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(
                  l10n.removePhotoAction,
                  style: designSans(
                    theme.textTheme.labelLarge,
                    color: DesignColors.destructiveText,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showBarcodePrintComingSoon,
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.textMuted,
                side: const BorderSide(color: DesignColors.cardBorder),
              ),
              icon: const Icon(Icons.qr_code_2_outlined, size: 18),
              label: Text(
                l10n.printBarcodeAction,
                style: designSans(
                  theme.textTheme.labelLarge,
                  color: DesignColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    const brandTeal = Color(0xFF0E7C7B);
    const brandTerracotta = Color(0xFFE4572E);
    final isLowStock = product.stockQuantity <= product.minStock;

    final ceiling = product.minStock > 0
        ? product.minStock * 3
        : (product.stockQuantity > 0 ? product.stockQuantity : 1.0);
    final ratio = (product.stockQuantity / ceiling).clamp(0.0, 1.0);
    final minMarkerRatio = product.minStock > 0
        ? (product.minStock / ceiling).clamp(0.0, 1.0)
        : null;

    String? weeksNote;
    if (_dailyVelocity > 0) {
      final weeks = product.stockQuantity / (_dailyVelocity * 7);
      weeksNote = l10n.stockWillLastNote(
        '${weeks.toStringAsFixed(1)} ${l10n.weeksSuffix}',
      );
    }

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(l10n.stockStatusLabel),
          const SizedBox(height: 16),
          _statRow(
            theme,
            l10n.minimumStockLabel,
            formatQuantity(product.minStock, product.unitType),
          ),
          const SizedBox(height: 6),
          _statRow(
            theme,
            l10n.currentStockLabel,
            formatQuantity(product.stockQuantity, product.unitType),
            valueColor: isLowStock ? brandTerracotta : brandTeal,
          ),
          const SizedBox(height: 12),
          _StockBar(ratio: ratio, minMarkerRatio: minMarkerRatio),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  theme,
                  l10n.unitTypeLabel,
                  _unitLabel(l10n, product.unitType),
                ),
              ),
              Expanded(
                child: _miniStat(
                  theme,
                  l10n.batchesLabel,
                  '${_batches.length}',
                  mono: true,
                ),
              ),
            ],
          ),
          if (weeksNote != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLowStock
                    ? brandTerracotta.withValues(alpha: 0.1)
                    : DesignColors.tealTint,
                borderRadius: BorderRadius.circular(DesignRadii.inner),
                border: isLowStock
                    ? Border.all(color: brandTerracotta.withValues(alpha: 0.3))
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isLowStock
                        ? Icons.warning_amber_rounded
                        : Icons.insights_outlined,
                    size: 16,
                    color: isLowStock ? brandTerracotta : DesignColors.teal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weeksNote,
                      style: designSans(
                        theme.textTheme.bodySmall,
                        color: isLowStock
                            ? brandTerracotta
                            : DesignColors.tealHover,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: designSans(
            theme.textTheme.bodyMedium,
            color: DesignColors.textMuted,
          ),
        ),
        Text(
          value,
          style: designMono(
            theme.textTheme.bodyMedium,
            color: valueColor ?? DesignColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    ThemeData theme,
    String label,
    String value, {
    bool mono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: designSans(
            theme.textTheme.labelSmall,
            color: DesignColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: mono
              ? designMono(
                  theme.textTheme.bodyMedium,
                  color: DesignColors.textPrimary,
                  fontWeight: FontWeight.w700,
                )
              : designSans(
                  theme.textTheme.bodyMedium,
                  color: DesignColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Right column: product info + batches + movements (+ variants)
  // -------------------------------------------------------------------
  Widget _buildRightColumn(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(context, l10n, theme, product),
        const SizedBox(height: 20),
        _buildBatchesCard(context, l10n, theme, product),
        const SizedBox(height: 20),
        _buildMovementsCard(context, l10n, theme, product),
        if (_variants.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildVariantsCard(context, l10n, theme),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    final status = statusOf(product);
    final hasBarcode =
        product.barcode != null && product.barcode!.trim().isNotEmpty;
    final hasVariant =
        product.variantSize != null && product.variantSize!.trim().isNotEmpty;

    final rows = <(String, String, bool)>[
      (l10n.productCodeLabel, product.code, true),
      (l10n.colProductId, '#${product.id}', true),
      (l10n.colProductName, product.name, false),
      if (product.categoryId != null) (l10n.colCategory, _categoryName, false),
      if (hasBarcode) (l10n.colBarcode, product.barcode!, true),
      if (hasVariant) (l10n.sizeVariantLabel, product.variantSize!, false),
      (l10n.unitTypeLabel, _unitLabel(l10n, product.unitType), false),
      (l10n.sellingPriceLabel, sellingPriceText(product, l10n), true),
      (
        l10n.currentStockLabel,
        formatQuantity(product.stockQuantity, product.unitType),
        true,
      ),
      (
        l10n.minimumStockLabel,
        formatQuantity(product.minStock, product.unitType),
        true,
      ),
      (l10n.colStatus, statusLabel(status, l10n), false),
      (l10n.colPurchaseDate, _formatDate(product.createdAt), true),
    ];

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(l10n.productInfoPanel),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 20.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 14,
                children: rows
                    .map(
                      (r) => SizedBox(
                        width: itemWidth,
                        child: _infoItem(theme, r.$1, r.$2, r.$3),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoItem(ThemeData theme, String label, String value, bool mono) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: designSans(
            theme.textTheme.bodySmall,
            color: DesignColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: mono
                ? designMono(
                    theme.textTheme.bodyMedium,
                    color: DesignColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  )
                : designSans(
                    theme.textTheme.bodyMedium,
                    color: DesignColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchesCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    return DesignCard(
      padding: _batches.isEmpty
          ? const EdgeInsets.all(20)
          : const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(l10n.batchesLabel),
          const SizedBox(height: 4),
          Text(
            l10n.batchesPanelDesc,
            style: designSans(
              theme.textTheme.bodySmall,
              color: DesignColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          if (_batches.isEmpty)
            EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noBatchesYet,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            l10n.colBatch,
                            style: designSans(theme.textTheme.labelMedium),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            l10n.colRemainingQuantity,
                            style: designSans(theme.textTheme.labelMedium),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            l10n.colBuyPrice,
                            style: designSans(theme.textTheme.labelMedium),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            l10n.colTotalValue,
                            style: designSans(theme.textTheme.labelMedium),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            l10n.colPurchaseDate,
                            style: designSans(theme.textTheme.labelMedium),
                          ),
                        ),
                      ],
                      rows: _batches.asMap().entries.map((entry) {
                        final i = entry.key;
                        final b = entry.value;
                        final isNextOut =
                            i ==
                            0; // getBatches() is oldest-first — index 0 sells first (FIFO)
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'BT-${b.id}',
                                    style: designMono(
                                      theme.textTheme.bodyMedium,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isNextOut) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: DesignColors.tealTint,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        l10n.nextOutTag,
                                        style: designSans(
                                          theme.textTheme.labelSmall,
                                          color: DesignColors.teal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                formatQuantity(b.quantity, product.unitType),
                                style: designMono(theme.textTheme.bodyMedium),
                              ),
                            ),
                            DataCell(
                              MoneyText(
                                formatMoney(b.buyPrice),
                                style: designMono(theme.textTheme.bodyMedium),
                              ),
                            ),
                            DataCell(
                              MoneyText(
                                formatMoney(b.quantity * b.buyPrice),
                                style: designMono(
                                  theme.textTheme.bodyMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatDate(b.purchaseDate),
                                style: designMono(
                                  theme.textTheme.bodyMedium,
                                  color: DesignColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMovementsCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Product product,
  ) {
    // _movements is newest-first; the running total right after the newest
    // movement is simply the product's current stock, and each older
    // movement's running total is derived by undoing the newer ones in turn.
    final preview = _movements.take(5).toList();
    final runningTotals = <double>[];
    var running = product.stockQuantity;
    for (final m in preview) {
      runningTotals.add(running);
      final delta = m.direction == 'in' ? m.quantity : -m.quantity;
      running -= delta;
    }

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(
            l10n.stockMovementsTitle,
            trailing: _movements.isEmpty
                ? null
                : TextButton(
                    onPressed: _openMovements,
                    child: Text(
                      l10n.viewAllAction,
                      style: designSans(
                        theme.textTheme.labelMedium,
                        color: DesignColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          if (preview.isEmpty)
            EmptyState(icon: Icons.history, title: l10n.noMovementsRecorded)
          else
            Column(
              children: List.generate(preview.length, (i) {
                final m = preview[i];
                final isOut = m.direction == 'out';
                final dotColor = isOut
                    ? const Color(0xFFE4572E)
                    : const Color(0xFF16A34A);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == preview.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.note ?? m.type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: designSans(
                                theme.textTheme.bodyMedium,
                                color: DesignColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatDate(m.createdAt),
                              style: designMono(
                                theme.textTheme.labelSmall,
                                color: DesignColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isOut ? '-' : '+'}${formatQuantity(m.quantity, product.unitType)}',
                            style: designMono(
                              theme.textTheme.bodyMedium,
                              color: dotColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            formatQuantity(runningTotals[i], product.unitType),
                            style: designMono(
                              theme.textTheme.labelSmall,
                              color: DesignColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantsCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return DesignCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignSectionTitle(l10n.variantsPanel),
          const SizedBox(height: 4),
          Text(
            l10n.variantsPanelDesc,
            style: designSans(
              theme.textTheme.bodySmall,
              color: DesignColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ..._variants.map((v) {
            final vLowStock = v.stockQuantity <= v.minStock;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz, color: DesignColors.teal),
              title: Text(
                productDisplayName(v),
                style: designSans(
                  theme.textTheme.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                vLowStock
                    ? l10n.lowStockLeftSuffix(
                        formatQuantity(v.stockQuantity, v.unitType),
                      )
                    : l10n.inStockCount(
                        formatQuantity(v.stockQuantity, v.unitType),
                      ),
                style: designSans(
                  theme.textTheme.bodySmall,
                  color: DesignColors.textMuted,
                ),
              ),
              trailing: MoneyText(
                v.sellingPrice != null
                    ? formatMoney(v.sellingPrice!)
                    : l10n.notSet,
                style: designMono(
                  theme.textTheme.bodyMedium,
                  color: DesignColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => _openVariant(v),
            );
          }),
        ],
      ),
    );
  }
}

class _CodePill extends StatelessWidget {
  final String code;
  const _CodePill(this.code);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DesignColors.tealTint,
        borderRadius: BorderRadius.circular(DesignRadii.inner),
      ),
      child: Text(
        code,
        style: designMono(
          theme.textTheme.labelMedium,
          color: DesignColors.teal,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Active/Archived pill. Archived is intentionally neutral gray, not red —
/// it's an inactive state, not a warning.
class _ActiveStatusPill extends StatelessWidget {
  final bool isArchived;
  final String label;
  const _ActiveStatusPill({required this.isArchived, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const success = Color(0xFF16A34A);
    final (bg, fg) = isArchived
        ? (
            DesignColors.cardBorder.withValues(alpha: 0.5),
            DesignColors.textMuted,
          )
        : (success.withValues(alpha: 0.12), success);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: designSans(
          theme.textTheme.labelSmall,
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StockBar extends StatelessWidget {
  final double ratio;
  final double? minMarkerRatio;
  const _StockBar({required this.ratio, this.minMarkerRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 10,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: DesignColors.tealTint,
                  valueColor: const AlwaysStoppedAnimation(DesignColors.teal),
                ),
              ),
              if (minMarkerRatio != null)
                Positioned(
                  left: (width * minMarkerRatio!).clamp(0, width - 2),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: DesignColors.warningText.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AddStockDialog extends StatefulWidget {
  final ProductRepository repo;
  final Product product;
  const _AddStockDialog({required this.repo, required this.product});

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  late final InsightsRepository _insightsRepo = InsightsRepository(
    widget.repo.db,
  );
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  late final _sellingPriceController = TextEditingController(
    text: widget.product.sellingPrice != null
        ? plainNumber(widget.product.sellingPrice!)
        : '',
  );
  DateTime _purchaseDate = DateTime.now();
  bool _saving = false;
  bool _isOpeningStock = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  bool get _isPiece => widget.product.unitType == 'piece';

  Future<void> _save() async {
    var quantity = double.tryParse(_quantityController.text) ?? 0;
    if (_isPiece) quantity = quantity.roundToDouble();
    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0;
    if (quantity <= 0 || sellingPrice <= 0) return;
    if (!_isOpeningStock && buyPrice <= 0) return;

    setState(() => _saving = true);
    await widget.repo.addStock(
      productId: widget.product.id,
      quantity: quantity,
      buyPrice: buyPrice,
      purchaseDate: _purchaseDate,
      sellingPrice: sellingPrice,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EnterToSubmit(
      onSubmit: _saving ? null : _save,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_box_outlined,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.addStock,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  value: _isOpeningStock,
                  onChanged: (v) =>
                      setState(() => _isOpeningStock = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    l10n.openingStockToggleLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: l10n.quantityLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: _isPiece
                            ? TextInputType.number
                            : const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _buyPriceController,
                        decoration: InputDecoration(
                          labelText: _isOpeningStock
                              ? l10n.estimatedCostOptionalLabel
                              : l10n.buyPriceLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _sellingPriceController,
                  decoration: InputDecoration(
                    labelText: l10n.sellingPriceFieldLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (widget.product.categoryId != null &&
                    (double.tryParse(_buyPriceController.text) ?? 0) > 0)
                  FutureBuilder<double?>(
                    future: _insightsRepo.suggestSellingPrice(
                      widget.product.categoryId!,
                      double.tryParse(_buyPriceController.text) ?? 0,
                    ),
                    builder: (context, snapshot) {
                      final suggestion = snapshot.data;
                      if (suggestion == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.suggestedPriceHint(
                                  formatMoney(suggestion),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _sellingPriceController.text =
                                    plainNumber(suggestion),
                              ),
                              child: Text(l10n.useSuggestionAction),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.purchaseDateLabel,
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            onPressed: _saving ? null : _save,
            child: Text(
              _isOpeningStock ? l10n.addOpeningStockAction : l10n.addStock,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementsDialog extends StatelessWidget {
  final ProductRepository repo;
  final Product product;
  const _MovementsDialog({required this.repo, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.stockMovementsTitle),
      content: SizedBox(
        width: 480,
        height: 400,
        child: FutureBuilder<List<StockMovement>>(
          future: repo.getMovements(product.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final movements = snapshot.data!;
            if (movements.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.history,
                  title: l10n.noMovementsRecorded,
                ),
              );
            }
            return ListView.separated(
              itemCount: movements.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = movements[i];
                final isOut = m.direction == 'out';
                return ListTile(
                  leading: Icon(
                    isOut ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isOut
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                  ),
                  title: Text(m.note ?? m.type),
                  subtitle: Text(
                    '${m.createdAt.year}-${m.createdAt.month.toString().padLeft(2, '0')}-${m.createdAt.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    '${isOut ? '-' : '+'}${formatQuantity(m.quantity, product.unitType)}',
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
