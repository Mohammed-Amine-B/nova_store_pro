import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/repositories/return_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

class StartReturnScreen extends StatefulWidget {
  final AppDatabase db;
  const StartReturnScreen({super.key, required this.db});

  @override
  State<StartReturnScreen> createState() => _StartReturnScreenState();
}

class _StartReturnScreenState extends State<StartReturnScreen> {
  late final SalesRepository _salesRepo = SalesRepository(widget.db);
  late final ReturnRepository _returnRepo = ReturnRepository(widget.db);
  final _searchController = TextEditingController();
  List<Sale> _matches = [];
  Sale? _selectedSale;
  List<SaleItem> _items = [];
  final Map<int, TextEditingController> _qtyControllers = {};
  String _reason = 'damaged';
  final _noteController = TextEditingController();
  String? _error;
  bool _submitting = false;

  Future<void> _search(String query) async {
    // Simple approach: search recent sales by product name isn't wired yet in SalesRepository,
    // so we search by sale id or fall back to recent sales. Adjust this if you have a better
    // search method already — this just lists the most recent 20 sales for now.
    final all = await _salesRepo.getRecentSales(limit: 20);
    setState(() => _matches = all);
  }

  Future<void> _pickSale(Sale sale) async {
    final items = await _salesRepo.getItemsForSale(sale.id);
    setState(() {
      _selectedSale = sale;
      _items = items;
      _qtyControllers.clear();
      for (final item in items) {
        _qtyControllers[item.id] = TextEditingController(text: '0');
      }
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedSale == null) return;
    final lines = <ReturnLineInput>[];
    for (final item in _items) {
      final qty = double.tryParse(_qtyControllers[item.id]!.text) ?? 0;
      if (qty > 0) lines.add(ReturnLineInput(saleItemId: item.id, quantity: qty));
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
        saleId: _selectedSale!.id,
        reason: _reason,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        lines: lines,
      );
      if (!mounted) return;
      final message = result.cashRefund > 0
          ? l10n.returnRecordedCashMsg(result.cashRefund.toStringAsFixed(2))
          : l10n.returnRecordedDebtMsg(result.totalRefunded.toStringAsFixed(2));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _selectedSale = null;
        _items = [];
        _submitting = false;
      });
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: l10n.startReturnTitle, subtitle: l10n.startReturnSubtitle),
          if (_selectedSale == null) ...[
            Panel(
              title: l10n.findSalePanel,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.recentSalesHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: _search,
                    ),
                    const SizedBox(height: 12),
                    if (_matches.isEmpty)
                      TextButton(onPressed: () => _search(''), child: Text(l10n.showRecentSalesAction)),
                    ..._matches.map((s) => ListTile(
                          title: Text('${s.totalAmount.toStringAsFixed(2)} DA'),
                          subtitle: Text('${s.date}'),
                          onTap: () => _pickSale(s),
                        )),
                  ],
                ),
              ),
            ),
          ] else ...[
            Panel(
              title: l10n.returnItemsPanel,
              description: l10n.enterQtyToReturnDesc,
              child: Column(
                children: [
                  ..._items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(l10n.productHashLabel('${item.productId}', '${item.quantity}', item.unitPrice.toStringAsFixed(2)))),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _qtyControllers[item.id],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(labelText: l10n.returnQtyLabel, border: const OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _reason,
                          decoration: InputDecoration(labelText: l10n.reasonLabel, border: const OutlineInputBorder()),
                          items: [
                            DropdownMenuItem(value: 'damaged', child: Text(l10n.reasonDamaged)),
                            DropdownMenuItem(value: 'wrong_item', child: Text(l10n.reasonWrongItem)),
                            DropdownMenuItem(value: 'changed_mind', child: Text(l10n.reasonChangedMind)),
                            DropdownMenuItem(value: 'other', child: Text(l10n.reasonOther)),
                          ],
                          onChanged: (v) => setState(() => _reason = v!),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(labelText: l10n.noteOptionalLabel, border: const OutlineInputBorder()),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(onPressed: () => setState(() => _selectedSale = null), child: Text(l10n.backAction)),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: Text(l10n.confirmReturnAction),
                            ),
                          ],
                        ),
                      ],
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
}
