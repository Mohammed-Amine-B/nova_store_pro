import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_status.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'product_form_dialog.dart';
import 'product_detail_screen.dart';
import '../../widgets/category_chip.dart';
import '../../utils/formatting.dart';
import '../../utils/product_images.dart';

enum StockFilter { all, low, out }

class ProductsScreen extends StatefulWidget {
  final AppDatabase db;
  const ProductsScreen({super.key, required this.db});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductRepository _repo = ProductRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);
  bool _showingArchived = false;

  List<Product> _all = [];
  List<Category> _categories = [];
  double _stockValue = 0;
  bool _loading = true;

  final _searchController = TextEditingController();
  int? _categoryFilter;
  StockFilter _stockFilter = StockFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = _showingArchived ? await _repo.getArchived() : await _repo.getAllActive();
    final cats = await _categoryRepo.getAllWithCounts();
    final stockValue = await _repo.stockValueAtBuyPrice();
    if (!mounted) return;
    setState(() {
      _all = all;
      _categories = cats.map((c) => c.category).toList();
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

  Future<void> _deletePermanently(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deletePermanentlyTitle,
      message: l10n.deletePermanentlyMessage(product.name),
      confirmLabel: l10n.deletePermanentlyAction,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_forever_outlined,
    );
    if (!confirmed) return;
    try {
      await _repo.deletePermanently(product.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  List<Product> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
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
      if (_stockFilter == StockFilter.low && status != ProductStatus.lowStock) {
        return false;
      }
      if (_stockFilter == StockFilter.out && status != ProductStatus.outOfStock) {
        return false;
      }
      return true;
    }).toList();
  }

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
                  icon: Icon(_showingArchived ? Icons.inventory_2_outlined : Icons.archive_outlined, size: 18),
                  label: Text(_showingArchived ? l10n.viewActive : l10n.viewArchived),
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
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
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
            ],
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
                if (!_showingArchived)
                  SegmentedButton<StockFilter>(
                    segments: [
                      ButtonSegment(
                        value: StockFilter.all,
                        label: Text(l10n.filterAll),
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
              ],
            ),
            child: rows.isEmpty
                ? EmptyState(icon: Icons.inventory_2_outlined, title: l10n.noProductsMatch)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                                return Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.04);
                              }
                              return null;
                            }),
                            columnSpacing: 28,
                            horizontalMargin: 20,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 64,
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
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FutureBuilder<String?>(
                                          future: resolveProductImagePath(p.imagePath),
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null) {
                                              return CircleAvatar(
                                                radius: 15,
                                                backgroundImage: FileImage(File(snapshot.data!)),
                                              );
                                            }
                                            return CircleAvatar(
                                              radius: 15,
                                              backgroundColor: avatarColor
                                                  .withValues(alpha: 0.15),
                                              child: Text(
                                                p.name.isNotEmpty
                                                    ? p.name[0].toUpperCase()
                                                    : '?',
                                                style: TextStyle(
                                                  color: avatarColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
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
                                    Text(
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
                                      formatQuantity(p.stockQuantity, p.unitType),
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
                                            label: statusLabel(status, l10n),
                                            tone: tone,
                                          ),
                                  ),
                                  if (_showingArchived)
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => _restoreProduct(p),
                                            icon: const Icon(Icons.restore, size: 16),
                                            label: Text(l10n.restoreAction),
                                          ),
                                          IconButton(
                                            onPressed: () => _deletePermanently(p),
                                            icon: const Icon(
                                              Icons.delete_forever_outlined,
                                              size: 18,
                                              color: Color(0xFFE4572E),
                                            ),
                                            tooltip: l10n.deletePermanentlyAction,
                                          ),
                                        ],
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
        ],
      ),
    );
  }
}