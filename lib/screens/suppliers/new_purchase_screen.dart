import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/insights_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/panel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_thumbnail.dart';
import '../../widgets/money_text.dart';
import '../../utils/formatting.dart';

class _CartLine {
  final int? purchaseItemId;
  final Product product;
  final double quantity;
  final double buyPrice;
  final double? sellingPrice;
  _CartLine({
    this.purchaseItemId,
    required this.product,
    required this.quantity,
    required this.buyPrice,
    this.sellingPrice,
  });

  double get lineTotal => quantity * buyPrice;
}

class NewPurchaseScreen extends StatefulWidget {
  final AppDatabase db;
  final int? supplierId;
  final int? purchaseId;
  const NewPurchaseScreen({
    super.key,
    required this.db,
    this.supplierId,
    this.purchaseId,
  });

  bool get isEditMode => purchaseId != null;

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  late final SupplierRepository _supplierRepo = SupplierRepository(widget.db);
  late final PurchaseRepository _purchaseRepo = PurchaseRepository(widget.db);
  late final ProductRepository _productRepo = ProductRepository(widget.db);
  late final InsightsRepository _insightsRepo = InsightsRepository(widget.db);

  Supplier? _supplier;
  Purchase? _existingPurchase;
  double _previousOwed = 0;
  final List<_CartLine> _lines = [];
  final _amountPaidController = TextEditingController();
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

  Future<void> _load() async {
    if (widget.isEditMode) {
      final purchase = await _purchaseRepo.getPurchaseById(widget.purchaseId!);
      final items = await _purchaseRepo.getPurchaseItems(widget.purchaseId!);
      final supplier = await _supplierRepo.getById(purchase.supplierId);
      final owed = await _supplierRepo.getRemainingOwed(purchase.supplierId);
      final lines = <_CartLine>[];
      for (final item in items) {
        final product = await _productRepo.getById(item.productId);
        lines.add(
          _CartLine(
            purchaseItemId: item.id,
            product: product!,
            quantity: item.quantity,
            buyPrice: item.buyPrice,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _supplier = supplier;
        _existingPurchase = purchase;
        _previousOwed = owed;
        _lines.addAll(lines);
        _amountPaidController.text = plainNumber(purchase.amountPaid);
        _loading = false;
      });
    } else {
      final supplier = await _supplierRepo.getById(widget.supplierId!);
      final owed = await _supplierRepo.getRemainingOwed(widget.supplierId!);
      if (!mounted) return;
      setState(() {
        _supplier = supplier;
        _previousOwed = owed;
        _loading = false;
      });
    }
  }

  Future<void> _onProductSearchChanged(String query) async {
    final matches = await _productRepo.search(query);
    if (!mounted) return;
    setState(() => _productMatches = matches.take(6).toList());
  }

  Future<(double, double, double?)?> _askQuantityAndPrice(
    Product product,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final existingBatches = await _productRepo.getBatches(product.id);
    final isFirstBatch = existingBatches.isEmpty;

    final isPiece = product.unitType == 'piece';
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');
    final sellingPriceController = TextEditingController(
      text: product.sellingPrice != null
          ? plainNumber(product.sellingPrice!)
          : '',
    );
    var totalPriceMode = false;

    return showDialog<(double, double, double?)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final previewQuantity = double.tryParse(quantityController.text) ?? 0;
          final previewEnteredPrice =
              double.tryParse(priceController.text) ?? 0;
          final showPreview =
              totalPriceMode && previewQuantity > 0 && previewEnteredPrice > 0;
          final previewPerUnit = showPreview
              ? previewEnteredPrice / previewQuantity
              : 0.0;
          final unitLabel = product.unitType == 'kg' ? 'kg' : 'm';
          final effectiveBuyPrice = totalPriceMode
              ? previewPerUnit
              : previewEnteredPrice;

          return AlertDialog(
            title: Text(productDisplayName(product)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: l10n.quantityLabel,
                          ),
                          keyboardType: isPiece
                              ? TextInputType.number
                              : const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: totalPriceMode
                                ? l10n.totalPricePaidLabel
                                : l10n.buyPriceLabel,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                      ),
                    ],
                  ),
                  if (!isPiece) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: false,
                            label: Text(l10n.priceModePerUnit),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text(l10n.priceModeTotal),
                          ),
                        ],
                        selected: {totalPriceMode},
                        onSelectionChanged: (s) =>
                            setDialogState(() => totalPriceMode = s.first),
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: const Color(
                            0xFF0E7C7B,
                          ).withValues(alpha: 0.12),
                          selectedForegroundColor: const Color(0xFF0E7C7B),
                        ),
                      ),
                    ),
                  ],
                  if (showPreview) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.perUnitPreview(
                          formatMoney(previewPerUnit),
                          unitLabel,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                  if (isFirstBatch) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: sellingPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.sellingPriceRequiredFirstBatch,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    if (product.categoryId != null && effectiveBuyPrice > 0)
                      FutureBuilder<double?>(
                        future: _insightsRepo.suggestSellingPrice(
                          product.categoryId!,
                          effectiveBuyPrice,
                        ),
                        builder: (context, snapshot) {
                          final suggestion = snapshot.data;
                          if (suggestion == null)
                            return const SizedBox.shrink();
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setDialogState(
                                    () => sellingPriceController.text =
                                        plainNumber(suggestion),
                                  ),
                                  child: Text(l10n.useSuggestionAction),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  var quantity = double.tryParse(quantityController.text) ?? 0;
                  if (isPiece) quantity = quantity.roundToDouble();
                  final enteredPrice =
                      double.tryParse(priceController.text) ?? 0;
                  if (quantity <= 0 || enteredPrice <= 0) return;
                  final price = totalPriceMode
                      ? enteredPrice / quantity
                      : enteredPrice;
                  double? sellingPrice;
                  if (isFirstBatch) {
                    sellingPrice = double.tryParse(sellingPriceController.text);
                    if (sellingPrice == null || sellingPrice <= 0) return;
                  }
                  Navigator.pop(context, (quantity, price, sellingPrice));
                },
                child: Text(l10n.addLineAction),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addLine(Product product) async {
    _productSearchController.clear();
    setState(() => _productMatches = []);
    final result = await _askQuantityAndPrice(product);
    if (result == null) return;

    if (!widget.isEditMode) {
      setState(
        () => _lines.add(
          _CartLine(
            product: product,
            quantity: result.$1,
            buyPrice: result.$2,
            sellingPrice: result.$3,
          ),
        ),
      );
      return;
    }
    try {
      await _purchaseRepo.addPurchaseLine(
        purchaseId: widget.purchaseId!,
        productId: product.id,
        quantity: result.$1,
        buyPrice: result.$2,
        sellingPrice: result.$3,
      );
      await _reloadEditMode();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _removeLine(_CartLine line) async {
    if (!widget.isEditMode) {
      setState(() => _lines.remove(line));
      return;
    }
    try {
      await _purchaseRepo.removePurchaseLine(line.purchaseItemId!);
      await _reloadEditMode();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reloadEditMode() async {
    final purchase = await _purchaseRepo.getPurchaseById(widget.purchaseId!);
    final items = await _purchaseRepo.getPurchaseItems(widget.purchaseId!);
    final lines = <_CartLine>[];
    for (final item in items) {
      final product = await _productRepo.getById(item.productId);
      lines.add(
        _CartLine(
          purchaseItemId: item.id,
          product: product!,
          quantity: item.quantity,
          buyPrice: item.buyPrice,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _existingPurchase = purchase;
      _lines
        ..clear()
        ..addAll(lines);
      _amountPaidController.text = plainNumber(purchase.amountPaid);
      _error = null;
    });
  }

  double get _total => _lines.fold(0, (sum, l) => sum + l.lineTotal);
  double get _totalItems => _lines.fold(0, (sum, l) => sum + l.quantity);

  Future<void> _confirmNewPurchase() async {
    final l10n = AppLocalizations.of(context)!;
    if (_lines.isEmpty) {
      setState(() => _error = l10n.addAtLeastOneProduct);
      return;
    }
    final amount = _amountPaidController.text.isEmpty
        ? 0.0
        : double.tryParse(_amountPaidController.text);
    if (amount == null || amount < 0) {
      setState(() => _error = l10n.amountPaidRangeError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final total = _total;
      final transactionPaid = amount > total ? total : amount;
      final overpay = amount > total ? amount - total : 0.0;
      final purchaseId = await _purchaseRepo.createPurchase(
        supplierId: widget.supplierId!,
        purchaseDate: DateTime.now(),
        lines: _lines
            .map(
              (l) => PurchaseLineInput(
                productId: l.product.id,
                quantity: l.quantity,
                buyPrice: l.buyPrice,
                sellingPrice: l.sellingPrice,
              ),
            )
            .toList(),
        amountPaid: transactionPaid,
      );
      if (overpay > 0) {
        await _supplierRepo.recordPayment(
          supplierId: widget.supplierId!,
          amount: overpay,
          paymentDate: DateTime.now(),
          note: 'Extra payment on purchase #$purchaseId applied to balance',
        );
      }
      if (!mounted) return;
      if (overpay > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Purchase recorded. ${formatMoney(overpay)} extra applied to reduce balance.',
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
      }
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
    final supplier = _supplier;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          title: l10n.supplierAddProductsPanel,
          description: l10n.searchProductToPurchaseDesc,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _productSearchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchProductToAddHint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _onProductSearchChanged,
                ),
                if (_productMatches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._productMatches.map(
                    (p) => ListTile(
                      dense: true,
                      leading: ProductThumbnail(
                        imagePath: p.imagePath,
                        size: 36,
                      ),
                      title: Text(productDisplayName(p)),
                      subtitle: Text(p.barcode ?? p.code),
                      onTap: () => _addLine(p),
                    ),
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
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: l10n.noLinesAddedYet,
                  subtitle: l10n.searchProductAboveToStartPurchase,
                )
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
                            DataColumn(label: Text(l10n.colProduct)),
                            DataColumn(
                              label: Text(l10n.colQuantity),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(l10n.buyPriceLabel),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(l10n.colTotal),
                              numeric: true,
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: _lines.map((line) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Tooltip(
                                    message: productDisplayName(line.product),
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        productDisplayName(line.product),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    formatQuantity(
                                      line.quantity,
                                      line.product.unitType,
                                    ),
                                  ),
                                ),
                                DataCell(MoneyText(formatMoney(line.buyPrice))),
                                DataCell(
                                  MoneyText(
                                    formatMoney(line.lineTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: theme.colorScheme.error,
                                    ),
                                    onPressed: () => _removeLine(line),
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
                _SummaryRow(
                  l10n.colItems,
                  l10n.itemsUnitsCount(formatQuantity(_totalItems, 'unit')),
                ),
                const SizedBox(height: 10),
                _SummaryRow(l10n.subtotalRow, formatMoney(_total), isMoney: true),
                if (!widget.isEditMode) ...[
                  const SizedBox(height: 10),
                  _SummaryRow(
                    l10n.previousDebtRow,
                    formatBalance(_previousOwed).$1,
                  ),
                ],
                const SizedBox(height: 14),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEditMode ? l10n.totalLabel : l10n.totalDueRow,
                      style: theme.textTheme.bodyMedium,
                    ),
                    MoneyText(
                      formatMoney(
                        widget.isEditMode ? _total : _total + _previousOwed,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0E7C7B),
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
          title: l10n.paymentPanel,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: widget.isEditMode
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(
                        l10n.colPaid,
                        formatMoney(_existingPurchase?.amountPaid ?? 0),
                        isMoney: true,
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        l10n.colRemaining,
                        formatMoney(
                          (_existingPurchase?.totalAmount ?? 0) -
                              (_existingPurchase?.amountPaid ?? 0),
                        ),
                        isMoney: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.toRecordPaymentHintSupplier,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amountPaidRow,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _amountPaidController,
                        decoration: InputDecoration(
                          hintText: l10n.zeroFullyOnCreditHint,
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(
                                () => _amountPaidController.text = plainNumber(
                                  _total,
                                ),
                              ),
                              child: Text(l10n.payFullAction),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(
                                () => _amountPaidController.text = plainNumber(
                                  _total / 2,
                                ),
                              ),
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
              onPressed: _saving ? null : _confirmNewPurchase,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C7B),
              ),
              child: Text(
                l10n.confirmPurchaseAction,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
                    Text(
                      widget.isEditMode
                          ? l10n.editPurchaseTooltip
                          : l10n.newPurchaseAction,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isEditMode
                          ? l10n.editingPurchaseNum('${widget.purchaseId}')
                          : l10n.draftNotSaved,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (supplier != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          supplier.name.isNotEmpty
                              ? supplier.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        supplier.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.supplierOwedSuffix(
                          formatBalance(_previousOwed).$1,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [left, const SizedBox(height: 20), right],
                );
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
  final bool isMoney;
  const _SummaryRow(this.label, this.value, {this.isMoney = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        isMoney
            ? MoneyText(value, style: valueStyle)
            : Text(value, style: valueStyle),
      ],
    );
  }
}
