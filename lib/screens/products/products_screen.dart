import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/insights_repository.dart';
import '../../data/repositories/product_status.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/enter_to_submit.dart';
import '../../widgets/money_text.dart';
import '../../widgets/date_range_dialog.dart';
import 'product_form_dialog.dart';
import 'product_detail_screen.dart';
import '../../widgets/category_chip.dart';
import '../../utils/formatting.dart';
import '../../utils/product_images.dart';
import '../../utils/text_scale.dart';
import '../../widgets/horizontal_scroll_table.dart';

enum StockFilter { all, inStock, low, out }

enum UnitTypeFilter { all, piece, kg, meter }

enum PhotoFilter { all, hasPhoto, noPhoto }

enum ProductTypeFilter { all, normal, hasSizes }

class ProductsScreen extends StatefulWidget {
  final AppDatabase db;
  const ProductsScreen({super.key, required this.db});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductRepository _repo = ProductRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);
  late final SupplierRepository _supplierRepo = SupplierRepository(widget.db);
  late final InsightsRepository _insightsRepo = InsightsRepository(widget.db);
  bool _showingArchived = false;

  List<Product> _all = [];
  List<Category> _categories = [];
  List<Supplier> _suppliers = [];
  Set<int> _stagnantProductIds = {};
  double _stockValue = 0;
  bool _loading = true;

  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  int? _categoryFilter;
  StockFilter _stockFilter = StockFilter.all;
  UnitTypeFilter _unitTypeFilter = UnitTypeFilter.all;
  PhotoFilter _photoFilter = PhotoFilter.all;
  ProductTypeFilter _productTypeFilter = ProductTypeFilter.all;
  DateTimeRange? _dateAddedRange;
  bool _stagnantOnly = false;
  int? _lastSupplierFilter;
  Set<int>? _lastSupplierProductIds;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = _showingArchived
        ? await _repo.getArchived()
        : await _repo.getAllActive();
    final cats = await _categoryRepo.getAllWithCounts();
    final stockValue = await _repo.stockValueAtBuyPrice();
    final suppliers = await _supplierRepo.getAllActive();
    final stagnant = await _insightsRepo.getStagnantProducts();
    if (!mounted) return;
    setState(() {
      _all = all;
      _categories = cats.map((c) => c.category).toList();
      _suppliers = suppliers;
      _stagnantProductIds = stagnant.map((p) => p.id).toSet();
      _stockValue = stockValue;
      _loading = false;
    });
  }

  void _toggleArchivedView() {
    setState(() {
      _showingArchived = !_showingArchived;
      _loading = true;
    });
    _load();
  }

  Future<void> _restoreProduct(Product product) async {
    await _repo.unarchive(product.id);
    _load();
  }

  Future<void> _forceDeleteProduct(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ForceDeleteDialog(product: product),
    );
    if (confirmed != true) return;
    await _repo.forceDeleteWithHistory(product.id);
    if (!mounted) return;
    _load();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.forceDeleteSuccessMessage(product.name))),
    );
  }

  List<DataCell> _withRowContextMenu(List<DataCell> cells, Product product) {
    return cells
        .map(
          (cell) => DataCell(
            GestureDetector(
              onSecondaryTapUp: (details) =>
                  _showProductContextMenu(details.globalPosition, product),
              child: cell.child,
            ),
          ),
        )
        .toList();
  }

  Future<void> _showProductContextMenu(Offset position, Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(value: 'open', child: Text(l10n.openAction)),
        if (_showingArchived) ...[
          PopupMenuItem(value: 'restore', child: Text(l10n.restoreAction)),
          PopupMenuItem(
            value: 'forceDelete',
            child: Text(l10n.forceDeleteAction),
          ),
        ],
      ],
    );
    if (!mounted) return;
    switch (selected) {
      case 'open':
        _openDetail(product);
      case 'restore':
        _restoreProduct(product);
      case 'forceDelete':
        _forceDeleteProduct(product);
    }
  }

  List<Product> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    return _all.where((p) {
      if (q.isNotEmpty) {
        final matches =
            p.name.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q) ||
            (p.barcode ?? '').toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_categoryFilter != null && p.categoryId != _categoryFilter) {
        return false;
      }
      final status = statusOf(p);
      if (_stockFilter == StockFilter.inStock &&
          status != ProductStatus.inStock) {
        return false;
      }
      if (_stockFilter == StockFilter.low && status != ProductStatus.lowStock) {
        return false;
      }
      if (_stockFilter == StockFilter.out &&
          status != ProductStatus.outOfStock) {
        return false;
      }
      if (_unitTypeFilter != UnitTypeFilter.all) {
        final wanted = switch (_unitTypeFilter) {
          UnitTypeFilter.piece => 'piece',
          UnitTypeFilter.kg => 'kg',
          UnitTypeFilter.meter => 'meter',
          UnitTypeFilter.all => '',
        };
        if (p.unitType != wanted) return false;
      }
      if (minPrice != null || maxPrice != null) {
        if (p.sellingPrice == null) return false;
        if (minPrice != null && p.sellingPrice! < minPrice) return false;
        if (maxPrice != null && p.sellingPrice! > maxPrice) return false;
      }
      final hasPhoto = p.imagePath != null && p.imagePath!.trim().isNotEmpty;
      if (_photoFilter == PhotoFilter.hasPhoto && !hasPhoto) return false;
      if (_photoFilter == PhotoFilter.noPhoto && hasPhoto) return false;
      final hasSizes =
          p.variantSize != null && p.variantSize!.trim().isNotEmpty;
      if (_productTypeFilter == ProductTypeFilter.normal && hasSizes) {
        return false;
      }
      if (_productTypeFilter == ProductTypeFilter.hasSizes && !hasSizes) {
        return false;
      }
      if (_dateAddedRange != null) {
        final start = _dateAddedRange!.start;
        final end = _dateAddedRange!.end.add(const Duration(days: 1));
        if (p.createdAt.isBefore(start) || !p.createdAt.isBefore(end)) {
          return false;
        }
      }
      if (_stagnantOnly && !_stagnantProductIds.contains(p.id)) {
        return false;
      }
      if (_lastSupplierFilter != null &&
          (_lastSupplierProductIds == null ||
              !_lastSupplierProductIds!.contains(p.id))) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_stockFilter != StockFilter.all) count++;
    if (_unitTypeFilter != UnitTypeFilter.all) count++;
    if (_minPriceController.text.trim().isNotEmpty ||
        _maxPriceController.text.trim().isNotEmpty) {
      count++;
    }
    if (_photoFilter != PhotoFilter.all) count++;
    if (_productTypeFilter != ProductTypeFilter.all) count++;
    if (_dateAddedRange != null) count++;
    if (_stagnantOnly) count++;
    if (_lastSupplierFilter != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _stockFilter = StockFilter.all;
      _unitTypeFilter = UnitTypeFilter.all;
      _minPriceController.clear();
      _maxPriceController.clear();
      _photoFilter = PhotoFilter.all;
      _productTypeFilter = ProductTypeFilter.all;
      _dateAddedRange = null;
      _stagnantOnly = false;
      _lastSupplierFilter = null;
      _lastSupplierProductIds = null;
    });
  }

  Future<void> _pickDateAddedRange() async {
    final picked = await showCustomDateRangeDialog(
      context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialRange: _dateAddedRange,
    );
    if (picked != null) setState(() => _dateAddedRange = picked);
  }

  Future<void> _onLastSupplierChanged(int? supplierId) async {
    setState(() => _lastSupplierFilter = supplierId);
    if (supplierId == null) {
      setState(() => _lastSupplierProductIds = null);
      return;
    }
    final ids = await _repo.getProductIdsWithLastSupplier(supplierId);
    if (!mounted) return;
    setState(() => _lastSupplierProductIds = ids);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _categoryName(int? id) => _categories
      .firstWhere(
        (c) => c.id == id,
        orElse: () => Category(id: -1, name: '—', createdAt: DateTime.now()),
      )
      .name;

  Future<void> _openAddDialog({Product? editing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(
        repo: _repo,
        categories: _categories,
        editing: editing,
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _openDetail(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailScreen(db: widget.db, productId: product.id),
      ),
    );
    _load();
  }

  Widget _labeledField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildFiltersPanel(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      color: const Color(0xFF0E7C7B).withValues(alpha: 0.03),
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<UnitTypeFilter>(
              initialValue: _unitTypeFilter,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.unitTypeLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(
                  value: UnitTypeFilter.all,
                  child: Text(l10n.filterAll),
                ),
                DropdownMenuItem(
                  value: UnitTypeFilter.piece,
                  child: Text(l10n.unitTypePiece),
                ),
                DropdownMenuItem(
                  value: UnitTypeFilter.kg,
                  child: Text(l10n.unitTypeKg),
                ),
                DropdownMenuItem(
                  value: UnitTypeFilter.meter,
                  child: Text(l10n.unitTypeMeter),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _unitTypeFilter = v ?? UnitTypeFilter.all),
            ),
          ),
          if (!_showingArchived)
            _labeledField(
              l10n.colStatus,
              SegmentedButton<StockFilter>(
                segments: [
                  ButtonSegment(
                    value: StockFilter.all,
                    label: Text(l10n.filterAll),
                  ),
                  ButtonSegment(
                    value: StockFilter.inStock,
                    label: Text(l10n.statusInStock),
                  ),
                  ButtonSegment(
                    value: StockFilter.low,
                    label: Text(l10n.filterLowStock),
                  ),
                  ButtonSegment(
                    value: StockFilter.out,
                    label: Text(l10n.filterOutOfStock),
                  ),
                ],
                selected: {_stockFilter},
                onSelectionChanged: (s) =>
                    setState(() => _stockFilter = s.first),
              ),
            ),
          _labeledField(
            l10n.priceRangeLabel,
            SizedBox(
              width: 220,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.minPriceLabel,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.maxPriceLabel,
                        isDense: true,
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
            ),
          ),
          _labeledField(
            l10n.photoFilterLabel,
            SegmentedButton<PhotoFilter>(
              segments: [
                ButtonSegment(
                  value: PhotoFilter.all,
                  label: Text(l10n.filterAll),
                ),
                ButtonSegment(
                  value: PhotoFilter.hasPhoto,
                  label: Text(l10n.photoFilterHas),
                ),
                ButtonSegment(
                  value: PhotoFilter.noPhoto,
                  label: Text(l10n.photoFilterNone),
                ),
              ],
              selected: {_photoFilter},
              onSelectionChanged: (s) => setState(() => _photoFilter = s.first),
            ),
          ),
          _labeledField(
            l10n.productTypeFilterLabel,
            SegmentedButton<ProductTypeFilter>(
              segments: [
                ButtonSegment(
                  value: ProductTypeFilter.all,
                  label: Text(l10n.filterAll),
                ),
                ButtonSegment(
                  value: ProductTypeFilter.normal,
                  label: Text(l10n.normalProductOption),
                ),
                ButtonSegment(
                  value: ProductTypeFilter.hasSizes,
                  label: Text(l10n.productWithSizesOption),
                ),
              ],
              selected: {_productTypeFilter},
              onSelectionChanged: (s) =>
                  setState(() => _productTypeFilter = s.first),
            ),
          ),
          SizedBox(
            width: 260,
            child: InkWell(
              onTap: _pickDateAddedRange,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dateAddedLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _dateAddedRange != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: l10n.clearDateFilterTooltip,
                          onPressed: () =>
                              setState(() => _dateAddedRange = null),
                        )
                      : const Icon(Icons.calendar_today_outlined, size: 16),
                ),
                child: Text(
                  _dateAddedRange == null
                      ? l10n.anyDateLabel
                      : '${_formatDate(_dateAddedRange!.start)} → ${_formatDate(_dateAddedRange!.end)}',
                ),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int?>(
              initialValue: _lastSupplierFilter,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.lastSupplierLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.allSuppliers)),
                ..._suppliers.map(
                  (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                ),
              ],
              onChanged: _onLastSupplierChanged,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _stagnantOnly,
                activeColor: const Color(0xFF0E7C7B),
                onChanged: (v) => setState(() => _stagnantOnly = v ?? false),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  l10n.stagnantStockLabel,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final l10n = AppLocalizations.of(context)!;
    final rows = _filtered;
    final totalUnits = _all.fold<double>(0, (sum, p) => sum + p.stockQuantity);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.productsTitle,
            subtitle: l10n.productsSubtitle,
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _toggleArchivedView,
                  icon: Icon(
                    _showingArchived
                        ? Icons.inventory_2_outlined
                        : Icons.archive_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _showingArchived ? l10n.viewActive : l10n.viewArchived,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openAddDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addProduct),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final stats = [
                StatCard(
                  label: l10n.statTotalProducts,
                  value: '${_all.length}',
                  icon: Icons.inventory_2_outlined,
                  accentColor: const Color(0xFF0E7C7B),
                ),
                StatCard(
                  label: l10n.statTotalUnits,
                  value: formatQuantity(totalUnits, 'unit'),
                  icon: Icons.widgets_outlined,
                  accentColor: const Color(0xFFF2A93B),
                ),
                StatCard(
                  label: l10n.statStockValue,
                  value: formatMoney(_stockValue),
                  hint: l10n.atBuyPrice,
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: const Color(0xFF16A34A),
                ),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 152,
                ),
                itemCount: stats.length,
                itemBuilder: (context, i) => stats[i],
              );
            },
          ),
          const SizedBox(height: 24),
          Panel(
            title: l10n.allProductsPanel,
            description: l10n.shownOfTotal(rows.length, _all.length),
            actions: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: l10n.searchProductsHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _categoryFilter,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.allCategories),
                      ),
                      ..._categories.map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _categoryFilter = v),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _activeFilterCount > 0
                        ? const Color(0xFF0E7C7B)
                        : null,
                    side: _activeFilterCount > 0
                        ? const BorderSide(color: Color(0xFF0E7C7B))
                        : null,
                  ),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: Text(
                    _activeFilterCount > 0
                        ? '${l10n.filtersLabel} ($_activeFilterCount)'
                        : l10n.filtersLabel,
                  ),
                ),
                if (_activeFilterCount > 0)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(l10n.clearFiltersAction),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_filtersExpanded) ...[
                  _buildFiltersPanel(l10n),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                ],
                rows.isEmpty
                    ? EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.noProductsMatch,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return HorizontalScrollTable(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                showCheckboxColumn: false,
                                headingRowColor: WidgetStateProperty.all(
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.06),
                                ),
                                dataRowColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.04);
                                  }
                                  return null;
                                }),
                                columnSpacing: 28,
                                horizontalMargin: 20,
                                dataRowMinHeight: 56 * dataRowScale(context),
                                dataRowMaxHeight: 64 * dataRowScale(context),
                                columns: [
                                  DataColumn(label: Text(l10n.colProductName)),
                                  DataColumn(label: Text(l10n.colBarcode)),
                                  DataColumn(label: Text(l10n.colCategory)),
                                  DataColumn(
                                    label: Text(l10n.colSellingPrice),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text(l10n.colCurrentStock),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text(l10n.colStatus)),
                                  if (_showingArchived)
                                    DataColumn(label: Text(l10n.restoreAction)),
                                ],
                                rows: rows.map((p) {
                                  final status = statusOf(p);

                                  final tone = switch (status) {
                                    ProductStatus.inStock => BadgeTone.success,
                                    ProductStatus.lowStock => BadgeTone.warning,
                                    ProductStatus.outOfStock =>
                                      BadgeTone.destructive,
                                  };

                                  final stockColor = switch (status) {
                                    ProductStatus.inStock => const Color(
                                      0xFF16A34A,
                                    ),
                                    ProductStatus.lowStock => const Color(
                                      0xFFF2994A,
                                    ),
                                    ProductStatus.outOfStock => const Color(
                                      0xFFE4572E,
                                    ),
                                  };

                                  final avatarColor = colorForCategory(p.name);

                                  return DataRow(
                                    onSelectChanged: (_) => _openDetail(p),
                                    mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                                    cells: _withRowContextMenu([
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FutureBuilder<String?>(
                                              future: resolveProductImagePath(
                                                p.imagePath,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null) {
                                                  return CircleAvatar(
                                                    radius: 15,
                                                    backgroundImage: FileImage(
                                                      File(snapshot.data!),
                                                    ),
                                                  );
                                                }
                                                return CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: avatarColor
                                                      .withValues(alpha: 0.15),
                                                  child: Text(
                                                    p.name.isNotEmpty
                                                        ? p.name[0]
                                                              .toUpperCase()
                                                        : '?',
                                                    style: TextStyle(
                                                      color: avatarColor,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            Tooltip(
                                              message: productDisplayName(p),
                                              child: SizedBox(
                                                width: 200,
                                                child: Text(
                                                  productDisplayName(p),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(p.barcode ?? '—')),
                                      DataCell(
                                        CategoryChip(
                                          name: _categoryName(p.categoryId),
                                        ),
                                      ),
                                      DataCell(
                                        MoneyText(
                                          p.sellingPrice != null
                                              ? formatMoney(p.sellingPrice!)
                                              : '—',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0E7C7B),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          formatQuantity(
                                            p.stockQuantity,
                                            p.unitType,
                                          ),
                                          style: TextStyle(
                                            color: stockColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        _showingArchived
                                            ? StatusBadge(
                                                label: l10n.statusArchived,
                                                tone: BadgeTone.neutral,
                                              )
                                            : StatusBadge(
                                                label: statusLabel(
                                                  status,
                                                  l10n,
                                                ),
                                                tone: tone,
                                              ),
                                      ),
                                      if (_showingArchived)
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _restoreProduct(p),
                                                icon: const Icon(
                                                  Icons.restore,
                                                  size: 16,
                                                ),
                                                label: Text(l10n.restoreAction),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _forceDeleteProduct(p),
                                                icon: const Icon(
                                                  Icons.dangerous_outlined,
                                                  size: 18,
                                                  color: Color(0xFFE4572E),
                                                ),
                                                tooltip: l10n.forceDeleteAction,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ], p),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Requires the user to type the product's exact name before enabling the
/// destructive action — this deletes real sales/purchase/stock history
/// permanently, so a plain Yes/No isn't enough friction.
class _ForceDeleteDialog extends StatefulWidget {
  final Product product;
  const _ForceDeleteDialog({required this.product});

  @override
  State<_ForceDeleteDialog> createState() => _ForceDeleteDialogState();
}

class _ForceDeleteDialogState extends State<_ForceDeleteDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const color = Color(0xFFE4572E);
    return EnterToSubmit(
      onSubmit: _matches ? () => Navigator.pop(context, true) : null,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dangerous_outlined,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.forceDeleteTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.forceDeleteWarning(widget.product.name),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.forceDeleteTypeToConfirm(widget.product.name),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    setState(() => _matches = value == widget.product.name),
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
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: _matches ? () => Navigator.pop(context, true) : null,
            child: Text(l10n.forceDeleteAction),
          ),
        ],
      ),
    );
  }
}
