import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/panel.dart';
import '../../widgets/return_dialog.dart';
import '../../utils/formatting.dart';

class _CartLine {
  final int? saleItemId;
  final Product product;
  double quantity;
  double unitPrice;
  _CartLine({this.saleItemId, required this.product, required this.quantity, required this.unitPrice});

  double get lineTotal => quantity * unitPrice;
}

class CustomerSaleScreen extends StatefulWidget {
  final AppDatabase db;
  final int? customerId;
  final int? saleId;
  const CustomerSaleScreen({super.key, required this.db, this.customerId, this.saleId});

  bool get isEditMode => saleId != null;

  @override
  State<CustomerSaleScreen> createState() => _CustomerSaleScreenState();
}

class _CustomerSaleScreenState extends State<CustomerSaleScreen> {
  late final CustomerRepository _customerRepo = CustomerRepository(widget.db);
  late final SalesRepository _salesRepo = SalesRepository(widget.db);
  late final ReportRepository _reportRepo = ReportRepository(widget.db);

  Customer? _customer;
  Sale? _existingSale;
  double _previousBalance = 0;
  final List<_CartLine> _lines = [];
  final _amountPaidController = TextEditingController();
  List<Product> _frequentlySold = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  final _productSearchController = TextEditingController();
  List<Product> _productMatches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _loadFrequentlySold() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    final best = await _reportRepo.getBestSellingProducts(start, now.add(const Duration(days: 1)), limit: 6);
    final products = <Product>[];
    for (final b in best) {
      products.add(await _salesRepo.getProduct(b.productId));
    }
    if (!mounted) return;
    setState(() => _frequentlySold = products);
  }

  Future<void> _load() async {
    await _loadFrequentlySold();
    if (widget.isEditMode) {
      final sale = await _salesRepo.getSaleById(widget.saleId!);
      final items = await _salesRepo.getItemsForSale(widget.saleId!);
      final customer = sale.customerId != null ? await _customerRepo.getById(sale.customerId!) : null;
      final lines = <_CartLine>[];
      for (final item in items) {
        final product = await _salesRepo.getProduct(item.productId);
        lines.add(_CartLine(saleItemId: item.id, product: product, quantity: item.quantity, unitPrice: item.unitPrice));
      }
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _existingSale = sale;
        _lines.addAll(lines);
        _amountPaidController.text = plainNumber(sale.amountPaid);
        _loading = false;
      });
    } else {
      final customer = await _customerRepo.getById(widget.customerId!);
      final balance = await _customerRepo.getRemainingBalance(widget.customerId!);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _previousBalance = balance;
        _loading = false;
      });
    }
  }

  Future<void> _onProductSearchChanged(String query) async {
    final matches = await _salesRepo.searchProducts(query);
    if (!mounted) return;
    setState(() => _productMatches = matches);
  }

  Future<(double, double)?> _askQuantityAndPrice(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final isPiece = product.unitType == 'piece';
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: plainNumber(product.sellingPrice ?? 0));
    return showDialog<(double, double)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: l10n.quantityLabel),
                keyboardType: isPiece ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: l10n.colUnitPrice),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              var quantity = double.tryParse(quantityController.text) ?? 0;
              if (isPiece) quantity = quantity.roundToDouble();
              final price = double.tryParse(priceController.text) ?? 0;
              if (quantity <= 0 || price <= 0) return;
              Navigator.pop(context, (quantity, price));
            },
            child: Text(l10n.addAction),
          ),
        ],
      ),
    );
  }

  Future<void> _addLine(Product product) async {
    _productSearchController.clear();
    setState(() => _productMatches = []);
    final result = await _askQuantityAndPrice(product);
    if (result == null) return;

    if (!widget.isEditMode) {
      setState(() => _lines.add(_CartLine(product: product, quantity: result.$1, unitPrice: result.$2)));
      return;
    }
    try {
      await _salesRepo.addSaleLine(saleId: widget.saleId!, productId: product.id, quantity: result.$1, unitPrice: result.$2);
      await _reloadEditMode();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _editLine(_CartLine line) async {
    final result = await _askQuantityAndPrice(line.product);
    if (result == null) return;
    if (!widget.isEditMode) {
      setState(() {
        line.quantity = result.$1;
        line.unitPrice = result.$2;
      });
      return;
    }
    try {
      await _salesRepo.updateSaleItem(saleItemId: line.saleItemId!, newQuantity: result.$1, newUnitPrice: result.$2);
      await _reloadEditMode();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _removeLine(_CartLine line) {
    if (!widget.isEditMode) setState(() => _lines.remove(line));
  }

  Future<void> _returnLine(_CartLine line) async {
    await showReturnDialog(context, widget.db, widget.saleId!);
    await _reloadEditMode();
  }

  Future<void> _reloadEditMode() async {
    final sale = await _salesRepo.getSaleById(widget.saleId!);
    final items = await _salesRepo.getItemsForSale(widget.saleId!);
    final lines = <_CartLine>[];
    for (final item in items) {
      final product = await _salesRepo.getProduct(item.productId);
      lines.add(_CartLine(saleItemId: item.id, product: product, quantity: item.quantity, unitPrice: item.unitPrice));
    }
    if (!mounted) return;
    setState(() {
      _existingSale = sale;
      _lines
        ..clear()
        ..addAll(lines);
      _amountPaidController.text = plainNumber(sale.amountPaid);
      _error = null;
    });
  }

  double get _total => _lines.fold(0, (sum, l) => sum + l.lineTotal);
  double get _totalItems => _lines.fold(0, (sum, l) => sum + l.quantity);

  Future<void> _savePayment() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountPaidController.text);
    if (amount == null || amount < 0 || amount > _total) {
      setState(() => _error = l10n.amountPaidUpdateRangeError);
      return;
    }
    try {
      await _salesRepo.updateAmountPaid(saleId: widget.saleId!, newAmountPaid: amount);
      await _reloadEditMode();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.paymentUpdated)));
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _confirmNewSale() async {
    final l10n = AppLocalizations.of(context)!;
    if (_lines.isEmpty) {
      setState(() => _error = l10n.addAtLeastOneProduct);
      return;
    }
    final amount = _amountPaidController.text.isEmpty ? 0.0 : double.tryParse(_amountPaidController.text);
    if (amount == null || amount < 0 || amount > _total) {
      setState(() => _error = l10n.amountPaidRangeError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _salesRepo.createSale(
        date: DateTime.now(),
        lines: _lines.map((l) => SaleLineInput(productId: l.product.id, quantity: l.quantity, unitPrice: l.unitPrice)).toList(),
        customerId: widget.customerId,
        paymentMethod: amount >= _total ? 'cash' : (amount <= 0 ? 'credit' : 'split'),
        amountPaid: amount,
        source: 'customer_sale',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    final customer = _customer;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          title: l10n.customerAddProductsPanel,
          description: l10n.addProductsDesc,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _productSearchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchToSellHint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _onProductSearchChanged,
                ),
                if (_productMatches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._productMatches.map((p) => ListTile(
                        dense: true,
                        title: Text(p.name),
                        subtitle: Text(p.barcode ?? p.code),
                        trailing: Text(
                          p.sellingPrice != null ? formatMoney(p.sellingPrice!) : '—',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0E7C7B)),
                        ),
                        onTap: () => _addLine(p),
                      )),
                ],
                if (_frequentlySold.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.frequentlySoldLabel, style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.6,
                  )),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: _frequentlySold.map((p) {
                      final lowStock = p.stockQuantity <= p.minStock;
                      return InkWell(
                        onTap: () => _addLine(p),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  Text(
                                    p.sellingPrice != null ? formatMoney(p.sellingPrice!) : '—',
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0E7C7B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lowStock ? l10n.lowStockLeftSuffix(formatQuantity(p.stockQuantity, p.unitType)) : l10n.inStockCount(formatQuantity(p.stockQuantity, p.unitType)),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: lowStock ? const Color(0xFFE4572E) : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          title: l10n.cartPanel,
          description: l10n.cartLineCountDesc(_lines.length),
          child: _lines.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(l10n.noLinesAddedYet, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(l10n.tapProductAboveToStartSale, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(l10n.colProduct)),
                            DataColumn(label: Text(l10n.colQuantity), numeric: true),
                            DataColumn(label: Text(l10n.colUnitPrice), numeric: true),
                            DataColumn(label: Text(l10n.colTotal), numeric: true),
                            const DataColumn(label: Text('')),
                          ],
                          rows: _lines.map((line) {
                            return DataRow(cells: [
                              DataCell(Text(line.product.name)),
                              DataCell(Text(formatQuantity(line.quantity, line.product.unitType))),
                              DataCell(Text(formatMoney(line.unitPrice))),
                              DataCell(Text(formatMoney(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700))),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _editLine(line)),
                                  if (widget.isEditMode)
                                    IconButton(
                                      icon: const Icon(Icons.assignment_return_outlined, size: 18),
                                      tooltip: l10n.returnTooltip,
                                      onPressed: () => _returnLine(line),
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error),
                                      onPressed: () => _removeLine(line),
                                    ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          title: l10n.summaryPanel,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(l10n.colItems, l10n.itemsUnitsCount(formatQuantity(_totalItems, 'unit'))),
                const SizedBox(height: 10),
                _SummaryRow(l10n.subtotalRow, formatMoney(_total)),
                if (!widget.isEditMode) ...[
                  const SizedBox(height: 10),
                  _SummaryRow(l10n.previousBalanceRow, formatMoney(_previousBalance)),
                ],
                const SizedBox(height: 14),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.isEditMode ? l10n.totalLabel : l10n.totalDueRow, style: theme.textTheme.bodyMedium),
                    Text(
                      formatMoney(widget.isEditMode ? _total : _total + _previousBalance),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF0E7C7B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
                Panel(
          title: l10n.paymentPanel,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: widget.isEditMode
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(l10n.colPaid, formatMoney(_existingSale?.amountPaid ?? 0)),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        l10n.colRemaining,
                        formatMoney((_existingSale?.totalAmount ?? 0) - (_existingSale?.amountPaid ?? 0)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.toRecordPaymentHintCustomer,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.amountPaidRow, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _amountPaidController,
                        decoration: InputDecoration(hintText: l10n.zeroFullyOnCreditHint, border: const OutlineInputBorder(), prefixText: '\$ '),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _amountPaidController.text = plainNumber(_total)),
                              child: Text(l10n.payFullAction),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _amountPaidController.text = plainNumber(_total / 2)),
                              child: Text(l10n.halfNowAction),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        if (!widget.isEditMode) ...[
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _confirmNewSale,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0E7C7B)),
              child: Text(l10n.confirmSaleAction, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.isEditMode ? l10n.editSaleTitle : l10n.newCustomerSaleTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      widget.isEditMode ? l10n.editingSaleNum('${widget.saleId}') : l10n.draftNotSaved,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              if (customer != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                        child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (!widget.isEditMode) ...[
                        Text(l10n.balanceSuffix(formatMoney(_previousBalance)), style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(children: [left, const SizedBox(height: 20), right]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: left),
                  const SizedBox(width: 20),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}