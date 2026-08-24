import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_status.dart';
import '../../data/repositories/insights_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/panel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/crop_image_dialog.dart';
import '../../widgets/empty_state.dart';
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
  List<Product> _variants = [];
  String _categoryName = '—';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final product = await _repo.getById(widget.productId);
    final batches = await _repo.getBatches(widget.productId);
    final categoriesWithCounts = await _categoryRepo.getAllWithCounts();
    final categories = categoriesWithCounts.map((c) => c.category).toList();
    final variants = product != null
        ? await _repo.getVariants(product.name, excludeId: product.id)
        : <Product>[];

    String categoryName = '—';
    if (product?.categoryId != null) {
      categoryName = categories
          .firstWhere(
            (c) => c.id == product!.categoryId,
            orElse: () => Category(id: -1, name: '—', createdAt: DateTime.now()),
          )
          .name;
    }

    if (!mounted) return;
    setState(() {
      _product = product;
      _batches = batches;
      _variants = variants;
      _categoryName = categoryName;
      _categories = categories;
      _loading = false;
    });
  }

  Future<void> _openVariant(Product variant) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(db: widget.db, productId: variant.id),
      ),
    );
    _load();
  }

  Future<void> _editProduct() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(repo: _repo, categories: _categories, editing: _product),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.productDetailFallbackTitle)),
        body: Center(child: Text(l10n.productNoLongerExists)),
      );
    }

    final status = statusOf(product);
    final tone = switch (status) {
      ProductStatus.inStock => BadgeTone.success,
      ProductStatus.lowStock => BadgeTone.warning,
      ProductStatus.outOfStock => BadgeTone.destructive,
    };

    return Scaffold(
      appBar: AppBar(title: Text(productDisplayName(product)), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$_categoryName · Barcode ${product.barcode ?? "—"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                StatusBadge(label: statusLabel(status, l10n), tone: tone),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 800;
                final left = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Panel(
                      title: l10n.productInfoPanel,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String?>(
                                  future: resolveProductImagePath(product.imagePath),
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 180,
                                      height: 180,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).dividerColor),
                                      ),
                                      child: snapshot.data != null
                                          ? Image.file(File(snapshot.data!), fit: BoxFit.cover)
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_outlined,
                                                  size: 40,
                                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  l10n.noPhotoLabel,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: _changePhoto,
                                          icon: const Icon(Icons.upload_outlined, color: Color(0xFF0E7C7B)),
                                          label: Text(l10n.changePhotoAction, style: const TextStyle(color: Color(0xFF0E7C7B))),
                                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0E7C7B))),
                                        ),
                                      ),
                                      if (product.imagePath != null) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: _removePhoto,
                                            icon: const Icon(Icons.delete_outline, color: Color(0xFFE4572E)),
                                            label: Text(l10n.removePhotoAction, style: const TextStyle(color: Color(0xFFE4572E))),
                                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE4572E))),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                _InfoField(l10n.colCategory, _categoryName),
                                _InfoField(
                                  l10n.colBarcode,
                                  product.barcode ?? '—',
                                ),
                                _InfoField(
                                  l10n.minimumStockLabel,
                                  formatQuantity(product.minStock, product.unitType),
                                ),
                                _InfoField(
                                  l10n.batchesLabel,
                                  '${_batches.length}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _HighlightBox(
                                    l10n.currentStockLabel,
                                    formatQuantity(product.stockQuantity, product.unitType),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _HighlightBox(
                                    l10n.sellingPriceLabel,
                                    product.sellingPrice != null
                                        ? formatMoney(product.sellingPrice!)
                                        : l10n.notSet,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _HighlightBox(
                                    l10n.costPriceLabel,
                                    _batches.isNotEmpty
                                        ? formatMoney(_batches.last.buyPrice)
                                        : l10n.notSet,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Panel(
                      title: l10n.batchesLabel,
                      description: l10n.batchesPanelDesc,
                      child: _batches.isEmpty
                          ? EmptyState(icon: Icons.inventory_2_outlined, title: l10n.noBatchesYet)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text(l10n.colBatch)),
                                        DataColumn(
                                          label: Text(l10n.colBuyPrice),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.colRemainingQuantity,
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(l10n.colPurchaseDate),
                                        ),
                                      ],
                                      rows: _batches.asMap().entries.map((
                                        entry,
                                      ) {
                                        final i = entry.key;
                                        final b = entry.value;
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(l10n.batchHashLabel(i + 1)),
                                                  if (i == 0) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        l10n.nextOutTag,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(formatMoney(b.buyPrice))),
                                            DataCell(Text(formatQuantity(b.quantity, product.unitType))),
                                            DataCell(
                                              Text(
                                                '${b.purchaseDate.year}-${b.purchaseDate.month.toString().padLeft(2, '0')}-${b.purchaseDate.day.toString().padLeft(2, '0')}',
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
                    ),
                    if (_variants.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Panel(
                        title: l10n.variantsPanel,
                        description: l10n.variantsPanelDesc,
                        child: Column(
                          children: _variants.map((v) {
                            final vLowStock = v.stockQuantity <= v.minStock;
                            return ListTile(
                              leading: const Icon(Icons.swap_horiz, color: Color(0xFF0E7C7B)),
                              title: Text(productDisplayName(v)),
                              subtitle: Text(
                                vLowStock
                                    ? l10n.lowStockLeftSuffix(formatQuantity(v.stockQuantity, v.unitType))
                                    : l10n.inStockCount(formatQuantity(v.stockQuantity, v.unitType)),
                              ),
                              trailing: Text(
                                v.sellingPrice != null ? formatMoney(v.sellingPrice!) : l10n.notSet,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0E7C7B)),
                              ),
                              onTap: () => _openVariant(v),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                );

                final right = Panel(
                  title: l10n.quickActionsPanel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _openAddStock,
                            icon: const Icon(Icons.add_box_outlined),
                            label: Text(l10n.addStock),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openMovements,
                            icon: const Icon(Icons.history),
                            label: Text(l10n.viewStockMovements),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _editProduct,
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFFF2A93B)),
                            label: Text(l10n.editProduct, style: const TextStyle(color: Color(0xFFF2A93B))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF2A93B))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: product.isArchived
                              ? OutlinedButton.icon(
                                  onPressed: _restoreProduct,
                                  icon: const Icon(Icons.restore, color: Color(0xFF16A34A)),
                                  label: Text(l10n.restoreAction, style: const TextStyle(color: Color(0xFF16A34A))),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF16A34A))),
                                )
                              : OutlinedButton.icon(
                                  onPressed: _deleteProduct,
                                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                  label: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                  style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.error)),
                                ),
                        ),
                      ],
                    ),
                  ),
                );

                if (narrow) {
                  return Column(
                    children: [left, const SizedBox(height: 20), right],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 20),
                    SizedBox(width: 320, child: right),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  const _InfoField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  final String label;
  final String value;
  const _HighlightBox(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
  late final InsightsRepository _insightsRepo = InsightsRepository(widget.repo.db);
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  late final _sellingPriceController = TextEditingController(
    text: widget.product.sellingPrice != null
        ? plainNumber(widget.product.sellingPrice!)
        : '',
  );
  DateTime _purchaseDate = DateTime.now();
  bool _saving = false;

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
    if (quantity <= 0 || buyPrice <= 0 || sellingPrice <= 0) return;

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
    return AlertDialog(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                        : const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _buyPriceController,
                    decoration: InputDecoration(
                      labelText: l10n.buyPriceLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            if (widget.product.categoryId != null && (double.tryParse(_buyPriceController.text) ?? 0) > 0)
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
                            l10n.suggestedPriceHint(formatMoney(suggestion)),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _sellingPriceController.text = plainNumber(suggestion)),
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
          child: Text(l10n.addStock),
        ),
      ],
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
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final movements = snapshot.data!;
            if (movements.isEmpty)
              return Center(child: EmptyState(icon: Icons.history, title: l10n.noMovementsRecorded));
            return ListView.separated(
              itemCount: movements.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
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
