import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/database/database.dart';
import '../data/repositories/sales_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/product_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../screens/products/product_detail_screen.dart';
import 'confirm_dialog.dart';
import 'stat_card.dart';
import 'panel.dart';
import 'metrics_summary_card.dart';
import 'money_text.dart';
import 'category_chip.dart';
import 'product_thumbnail.dart';
import '../utils/formatting.dart';
import '../utils/text_scale.dart';
import 'return_dialog.dart';

class SalesDayView extends StatefulWidget {
  final AppDatabase db;
  final DateTime date;
  final String title;
  final String panelTitle;
  final Widget? actions;
  final Widget? topContent;
  final bool compact; // opt-in polished styling; false preserves original look
  final bool showTotalFooter;
  final bool
  dividedMetrics; // renders one divided metrics card instead of 3 grid StatCards
  final bool
  fourStatCards; // renders Transactions/Units Sold/Profit/Revenue(hero) row instead
  final bool showTimeColumn; // adds a Time column showing each sale's time
  final ValueChanged<int>? onSalesCountChanged;

  const SalesDayView({
    super.key,
    required this.db,
    required this.date,
    required this.title,
    required this.panelTitle,
    this.actions,
    this.topContent,
    this.compact = false,
    this.showTotalFooter = false,
    this.dividedMetrics = false,
    this.fourStatCards = false,
    this.showTimeColumn = false,
    this.onSalesCountChanged,
  });

  @override
  State<SalesDayView> createState() => SalesDayViewState();
}

class SalesDayViewState extends State<SalesDayView> {
  late final SalesRepository _repo = SalesRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);
  late final ProductRepository _productRepo = ProductRepository(widget.db);
  List<Sale> _sales = [];
  Map<int, List<SaleItem>> _itemsBySale = {};
  Map<int, Product> _productCache = {};
  Map<int, String> _categoryNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final sales = await _repo.getSalesForDate(widget.date);
    final itemsBySale = <int, List<SaleItem>>{};
    final productIds = <int>{};
    for (final s in sales) {
      final items = await _repo.getItemsForSale(s.id);
      itemsBySale[s.id] = items;
      productIds.addAll(items.map((i) => i.productId));
    }
    final productCache = <int, Product>{};
    for (final id in productIds) {
      productCache[id] = await _repo.getProduct(id);
    }
    final categoryNames = <int, String>{};
    try {
      for (final c in await _categoryRepo.getAllWithCounts()) {
        categoryNames[c.category.id] = c.category.name;
      }
    } catch (_) {
      // Non-critical — the quick-view dialog just falls back to '—'.
    }
    if (!mounted) return;
    setState(() {
      _sales = sales;
      _itemsBySale = itemsBySale;
      _productCache = productCache;
      _categoryNames = categoryNames;
      _loading = false;
    });
    widget.onSalesCountChanged?.call(sales.length);
  }

  Future<void> _showProductQuickView(int productId) async {
    final product = _productCache[productId];
    if (product == null) return;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Cost price isn't a field on Product itself — it's derived from the
    // most recent stock batch, same as product_detail_screen.dart does.
    final batches = await _productRepo.getBatches(productId);
    final costPrice = batches.isNotEmpty ? batches.last.buyPrice : null;
    if (!mounted) return;

    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    Widget row(String label, Widget value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: labelStyle),
              value,
            ],
          ),
        );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: ProductThumbnail(imagePath: product.imagePath, size: 44),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                productDisplayName(product),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 24, color: theme.dividerColor),
              row(
                l10n.colCategory,
                CategoryChip(name: _categoryNames[product.categoryId] ?? '—'),
              ),
              row(l10n.colBarcode, Text(product.barcode ?? product.code, style: valueStyle)),
              row(
                l10n.colCurrentStock,
                Text(
                  formatQuantity(product.stockQuantity, product.unitType),
                  style: valueStyle,
                ),
              ),
              row(
                l10n.costPriceLabel,
                MoneyText(
                  costPrice != null ? formatMoney(costPrice) : l10n.notSet,
                  style: valueStyle,
                ),
              ),
              row(
                l10n.colSellingPrice,
                MoneyText(
                  product.sellingPrice != null ? formatMoney(product.sellingPrice!) : l10n.notSet,
                  style: valueStyle?.copyWith(color: const Color(0xFF0E7C7B), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(db: widget.db, productId: product.id),
                ),
              );
              reload();
            },
            child: Text(l10n.productDetailsAction),
          ),
        ],
      ),
    );
  }

  List<(Sale, SaleItem)> get _rows {
    final rows = <(Sale, SaleItem)>[];
    for (final s in _sales) {
      for (final item in _itemsBySale[s.id] ?? []) {
        rows.add((s, item));
      }
    }
    return rows;
  }

  /// Prints a simple summary of the day's transactions (title, totals, and
  /// a line-item table) using the same `printing`-package pattern already
  /// used for invoices and purchase receipts elsewhere in the app.
  Future<void> printSummary() async {
    final revenue = _sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final profit = _sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    final units = _itemsBySale.values
        .expand((i) => i)
        .fold<double>(0, (sum, i) => sum + i.quantity);
    final rows = _rows;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Today Sales',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(DateFormat('EEEE, MMMM d, yyyy').format(widget.date)),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Transactions: ${_sales.length}'),
                pw.Text('Units Sold: ${formatQuantity(units, 'unit')}'),
                pw.Text('Profit: ${formatMoney(profit)}'),
                pw.Text('Revenue: ${formatMoney(revenue)}'),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Time', 'Product', 'Qty', 'Unit Price', 'Total'],
              data: rows.map((pair) {
                final sale = pair.$1;
                final item = pair.$2;
                final unitType =
                    _productCache[item.productId]?.unitType ?? 'piece';
                return [
                  DateFormat.Hm().format(sale.createdAt),
                  _productName(item.productId),
                  formatQuantity(item.quantity, unitType),
                  formatMoney(item.unitPrice),
                  formatMoney(item.quantity * item.unitPrice),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  String _productName(int id) {
    final product = _productCache[id];
    return product != null ? productDisplayName(product) : 'Deleted product';
  }

  Future<void> _editItem(SaleItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final unitType = _productCache[item.productId]?.unitType ?? 'piece';
    final isPiece = unitType == 'piece';
    final quantityController = TextEditingController(
      text: plainNumber(item.quantity),
    );
    final priceController = TextEditingController(
      text: plainNumber(item.unitPrice),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editSaleTitle),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: l10n.quantityLabel),
                keyboardType: isPiece
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: l10n.sellingPriceFieldLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
    if (saved != true) return;
    try {
      var newQuantity =
          double.tryParse(quantityController.text) ?? item.quantity;
      if (isPiece) newQuantity = newQuantity.roundToDouble();
      await _repo.updateSaleItem(
        saleItemId: item.id,
        newQuantity: newQuantity,
        newUnitPrice: double.tryParse(priceController.text) ?? item.unitPrice,
      );
      reload();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteSale(Sale sale) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteSaleTitle,
      message: l10n.deleteSaleMessage,
      confirmLabel: l10n.delete,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_outline,
    );
    if (confirmed) {
      await _repo.deleteSale(sale.id);
      reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final compact = widget.compact;

    final revenue = _sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final profit = _sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    final items = _itemsBySale.values
        .expand((i) => i)
        .fold<double>(0, (sum, i) => sum + i.quantity);

    final rows = _rows;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.topContent != null) widget.topContent!,
          if (widget.fourStatCards)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: StatCard(
                    label: l10n.statTransactions,
                    value: '${_sales.length}',
                    icon: Icons.receipt_long_outlined,
                    accentColor: const Color(0xFFF2994A),
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 12 : 16),
                Expanded(
                  flex: 3,
                  child: StatCard(
                    label: l10n.colUnitsSold,
                    value: formatQuantity(items, 'unit'),
                    icon: Icons.inventory_2_outlined,
                    accentColor: const Color(0xFFF2A93B),
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 12 : 16),
                Expanded(
                  flex: 3,
                  child: StatCard(
                    label: l10n.statProfit,
                    value: formatMoney(profit),
                    icon: Icons.trending_up,
                    accentColor: const Color(0xFF16A34A),
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 12 : 16),
                Expanded(
                  // Hero card: wider than the others to draw the eye to revenue.
                  flex: 4,
                  child: StatCard(
                    label: l10n.statRevenue,
                    value: formatMoney(revenue),
                    icon: Icons.account_balance_wallet_outlined,
                    accentColor: const Color(0xFF0E7C7B),
                    compact: compact,
                  ),
                ),
              ],
            )
          else if (widget.dividedMetrics)
            MetricsSummaryCard(
              items: [
                MetricItem(
                  label: l10n.statRevenue,
                  value: formatMoney(revenue),
                  hint: l10n.salesCount(_sales.length),
                  valueColor: const Color(0xFF0E7C7B),
                ),
                MetricItem(
                  label: l10n.statProfit,
                  value: formatMoney(profit),
                  hint: l10n.fifoHint,
                  valueColor: const Color(0xFF16A34A),
                ),
                MetricItem(
                  label: l10n.statSoldItems,
                  value: formatQuantity(items, 'unit'),
                  hint: l10n.salesCount(_sales.length),
                  valueColor: const Color(0xFFF2994A),
                ),
              ],
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: compact ? 12 : 16,
                crossAxisSpacing: compact ? 12 : 16,
                mainAxisExtent: compact ? 116 : 152,
              ),
              itemCount: 3,
              itemBuilder: (context, i) => [
                StatCard(
                  label: l10n.statRevenue,
                  value: formatMoney(revenue),
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: const Color(0xFF0E7C7B),
                  compact: compact,
                ),
                StatCard(
                  label: l10n.statProfit,
                  value: formatMoney(profit),
                  hint: l10n.fifoHint,
                  icon: Icons.trending_up,
                  accentColor: const Color(0xFF16A34A),
                  compact: compact,
                ),
                StatCard(
                  label: l10n.statSoldItems,
                  value: formatQuantity(items, 'unit'),
                  hint: l10n.salesCount(_sales.length),
                  icon: Icons.inventory_2_outlined,
                  accentColor: const Color(0xFFF2A93B),
                  compact: compact,
                ),
              ][i],
            ),
          SizedBox(height: compact ? 16 : 20),
          Panel(
            title: widget.panelTitle,
            description: l10n.transactionsCount(_sales.length),
            actions: widget.actions,
            child: rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.noSalesRecordedToday),
                  )
                : Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                headingRowColor: compact
                                    ? WidgetStateProperty.all(
                                        theme.colorScheme.primary.withValues(
                                          alpha: 0.05,
                                        ),
                                      )
                                    : null,
                                headingRowHeight: compact
                                    ? 40 * dataRowScale(context)
                                    : null,
                                dataRowMinHeight: compact
                                    ? 44 * dataRowScale(context)
                                    : null,
                                dataRowMaxHeight: compact
                                    ? 48 * dataRowScale(context)
                                    : null,
                                dataRowColor: compact
                                    ? WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.hovered,
                                        )) {
                                          return theme.colorScheme.primary
                                              .withValues(alpha: 0.03);
                                        }
                                        return null;
                                      })
                                    : null,
                                columns: [
                                  if (widget.showTimeColumn)
                                    DataColumn(label: Text(l10n.colTime)),
                                  DataColumn(label: Text(l10n.colProduct)),
                                  DataColumn(
                                    label: Text(l10n.colQuantity),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text(l10n.colUnitPrice),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text(l10n.colTotal),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text(l10n.colActions)),
                                ],
                                rows: rows.map((pair) {
                                  final sale = pair.$1;
                                  final item = pair.$2;
                                  final unitType =
                                      _productCache[item.productId]?.unitType ??
                                      'piece';
                                  return DataRow(
                                    cells: [
                                      if (widget.showTimeColumn)
                                        DataCell(
                                          Text(
                                            DateFormat.Hm(
                                              Localizations.localeOf(
                                                context,
                                              ).toString(),
                                            ).format(sale.createdAt),
                                            style: compact
                                                ? TextStyle(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      DataCell(
                                        GestureDetector(
                                          onDoubleTap: () =>
                                              _showProductQuickView(item.productId),
                                          child: Tooltip(
                                            message: _productName(item.productId),
                                            child: SizedBox(
                                              width: 220,
                                              child: Text(
                                                _productName(item.productId),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: compact
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          formatQuantity(
                                            item.quantity,
                                            unitType,
                                          ),
                                          style: compact
                                              ? TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                )
                                              : null,
                                        ),
                                      ),
                                      DataCell(
                                        MoneyText(
                                          formatMoney(item.unitPrice),
                                          style: compact
                                              ? TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                )
                                              : null,
                                        ),
                                      ),
                                      DataCell(
                                        MoneyText(
                                          formatMoney(
                                            item.quantity * item.unitPrice,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                              ),
                                              onPressed: () => _editItem(item),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .assignment_return_outlined,
                                                size: 18,
                                              ),
                                              tooltip: 'Return',
                                              onPressed: () async {
                                                await showReturnDialog(
                                                  context,
                                                  widget.db,
                                                  sale.id,
                                                );
                                                reload();
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: compact
                                                    ? theme.colorScheme.error
                                                    : null,
                                              ),
                                              onPressed: () =>
                                                  _deleteSale(sale),
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
                      if (widget.showTotalFooter) ...[
                        Divider(height: 1, color: theme.dividerColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                l10n.totalLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              MoneyText(
                                formatMoney(revenue),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0E7C7B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
