import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/repositories/sales_repository.dart';
import '../data/repositories/return_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/formatting.dart';

class ReturnDialog extends StatefulWidget {
  final AppDatabase db;
  final int saleId;
  const ReturnDialog({super.key, required this.db, required this.saleId});

  @override
  State<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  late final SalesRepository _salesRepo = SalesRepository(widget.db);
  late final ReturnRepository _returnRepo = ReturnRepository(widget.db);
  List<SaleItem> _items = [];
  Map<int, Product> _products = {};
  final Map<int, TextEditingController> _qtyControllers = {};
  String _reason = 'damaged';
  final _noteController = TextEditingController();
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _salesRepo.getItemsForSale(widget.saleId);
    final products = <int, Product>{};
    for (final item in items) {
      products[item.productId] = await _salesRepo.getProduct(item.productId);
    }
    if (!mounted) return;
    setState(() {
      _items = items;
      _products = products;
      for (final item in items) {
        _qtyControllers[item.id] = TextEditingController(text: '0');
      }
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final lines = <ReturnLineInput>[];
    for (final item in _items) {
      final qty = double.tryParse(_qtyControllers[item.id]!.text) ?? 0;
      if (qty > 0)
        lines.add(ReturnLineInput(saleItemId: item.id, quantity: qty));
    }
    if (lines.isEmpty) {
      setState(() => _error = l10n.enterQtyAtLeastOne);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _returnRepo.createReturn(
        saleId: widget.saleId,
        reason: _reason,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        lines: lines,
      );
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.returnItemsPanel),
      content: SizedBox(
        width: 400,
        child: _loading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._items.map((item) {
                      final product = _products[item.productId];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.returnLineDesc(
                                  product != null
                                      ? productDisplayName(product)
                                      : l10n.unknownProductLabel,
                                  '${item.quantity}',
                                  item.unitPrice.toStringAsFixed(2),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _qtyControllers[item.id],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.returnQtyLabel,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _reason,
                      decoration: InputDecoration(
                        labelText: l10n.reasonLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'damaged',
                          child: Text(l10n.reasonDamaged),
                        ),
                        DropdownMenuItem(
                          value: 'wrong_item',
                          child: Text(l10n.reasonWrongItem),
                        ),
                        DropdownMenuItem(
                          value: 'changed_mind',
                          child: Text(l10n.reasonChangedMind),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(l10n.reasonOther),
                        ),
                      ],
                      onChanged: (v) => setState(() => _reason = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: l10n.noteOptionalLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.confirmReturnAction),
        ),
      ],
    );
  }
}

Future<void> showReturnDialog(
  BuildContext context,
  AppDatabase db,
  int saleId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<ReturnResult>(
    context: context,
    builder: (context) => ReturnDialog(db: db, saleId: saleId),
  );
  if (result != null && context.mounted) {
    final message = result.cashRefund > 0
        ? l10n.returnRecordedCashMsg(result.cashRefund.toStringAsFixed(2))
        : l10n.returnRecordedDebtMsg(result.totalRefunded.toStringAsFixed(2));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
