import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/repositories/sales_repository.dart';
import '../l10n/generated/app_localizations.dart';
import 'confirm_dialog.dart';
import 'stat_card.dart';
import 'panel.dart';
import 'metrics_summary_card.dart';
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
  });

  @override
  State<SalesDayView> createState() => SalesDayViewState();
}

class SalesDayViewState extends State<SalesDayView> {
  late final SalesRepository _repo = SalesRepository(widget.db);
  List<Sale> _sales = [];
  Map<int, List<SaleItem>> _itemsBySale = {};
  Map<int, Product> _productCache = {};
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
    if (!mounted) return;
    setState(() {
      _sales = sales;
      _itemsBySale = itemsBySale;
      _productCache = productCache;
      _loading = false;
    });
  }

  String _productName(int id) {
    final product = _productCache[id];
    return product != null ? productDisplayName(product) : 'Deleted product';
  }

  Future<void> _editItem(SaleItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final unitType = _productCache[item.productId]?.unitType ?? 'piece';
    final isPiece = unitType == 'piece';
    final quantityController = TextEditingController(text: plainNumber(item.quantity));
    final priceController = TextEditingController(text: plainNumber(item.unitPrice));
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      var newQuantity = double.tryParse(quantityController.text) ?? item.quantity;
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

    final rows = <(Sale, SaleItem)>[];
    for (final s in _sales) {
      for (final item in _itemsBySale[s.id] ?? []) {
        rows.add((s, item));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.topContent != null) widget.topContent!,
          if (widget.dividedMetrics)
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
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: compact ? 12 : 16,
              crossAxisSpacing: compact ? 12 : 16,
              childAspectRatio: compact ? 3.3 : 2.4,
              children: [
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
              ],
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
                                headingRowHeight: compact ? 40 * dataRowScale(context) : null,
                                dataRowMinHeight: compact ? 44 * dataRowScale(context) : null,
                                dataRowMaxHeight: compact ? 48 * dataRowScale(context) : null,
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
                                      _productCache[item.productId]?.unitType ?? 'piece';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          _productName(item.productId),
                                          style: TextStyle(
                                            fontWeight: compact
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          formatQuantity(item.quantity, unitType),
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
                                        Text(
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
                                        Text(
                                          formatMoney(item.quantity * item.unitPrice),
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
                                              icon: const Icon(Icons.assignment_return_outlined, size: 18),
                                              tooltip: 'Return',
                                              onPressed: () async {
                                                await showReturnDialog(context, widget.db, sale.id);
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
                              Text(
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
