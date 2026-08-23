import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/panel.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatting.dart';
import 'supplier_form_dialog.dart';
import 'new_purchase_screen.dart';
import 'purchase_receipt_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final AppDatabase db;
  final int supplierId;
  const SupplierDetailScreen({
    super.key,
    required this.db,
    required this.supplierId,
  });

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late final SupplierRepository _repo = SupplierRepository(widget.db);
  late final PurchaseRepository _purchaseRepo = PurchaseRepository(widget.db);

  Supplier? _supplier;
  List<Purchase> _purchases = [];
  Map<int, int> _itemCounts = {};
  List<SupplierPayment> _payments = [];
  double _totalPurchased = 0;
  double _owed = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supplier = await _repo.getById(widget.supplierId);
    final purchases = await _purchaseRepo.getPurchasesForSupplier(widget.supplierId);
    final total = await _repo.totalPurchasedFrom(widget.supplierId);
    final owed = await _repo.getRemainingOwed(widget.supplierId);
    final payments = await _repo.getPaymentsForSupplier(widget.supplierId);
    final itemCounts = <int, int>{};
    for (final p in purchases) {
      final items = await _purchaseRepo.getPurchaseItems(p.id);
      itemCounts[p.id] = items.length;
    }

    if (!mounted) return;
    setState(() {
      _supplier = supplier;
      _purchases = purchases;
      _itemCounts = itemCounts;
      _payments = payments;
      _totalPurchased = total;
      _owed = owed;
      _loading = false;
    });
  }

  Future<void> _editSupplier() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => SupplierFormDialog(repo: _repo, editing: _supplier),
    );
    if (saved == true) _load();
  }

  Future<void> _archiveSupplier() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.removeSupplierTitle,
      message: l10n.removeSupplierMessage(_supplier!.name),
      confirmLabel: l10n.removeAction,
      tone: ConfirmTone.destructive,
      icon: Icons.archive_outlined,
    );
    if (confirmed) {
      await _repo.archive(_supplier!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _restoreSupplier() async {
    await _repo.unarchive(_supplier!.id);
    _load();
  }

  Future<void> _newPurchase() async {
    final l10n = AppLocalizations.of(context)!;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.newPurchaseAction), leading: const BackButton()),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: NewPurchaseScreen(db: widget.db, supplierId: _supplier!.id),
          ),
        ),
      ),
    );
    _load();
  }

  Future<void> _editPurchase(Purchase purchase) async {
    final l10n = AppLocalizations.of(context)!;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.editPurchaseTooltip), leading: const BackButton()),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: NewPurchaseScreen(db: widget.db, purchaseId: purchase.id),
          ),
        ),
      ),
    );
    _load();
  }

  Future<void> _recordPayment() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    var paymentDate = DateTime.now();
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.recordPaymentTitle),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error != null) ...[
                    Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: l10n.amountLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setDialogState(() => paymentDate = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.paymentDateLabel,
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: l10n.noteOptionalLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    setDialogState(() => error = l10n.enterValidAmount);
                    return;
                  }
                  if (amount > _owed) {
                    setDialogState(() => error = l10n.amountPaidExceedsTotal);
                    return;
                  }
                  await _repo.recordPayment(
                    supplierId: _supplier!.id,
                    amount: amount,
                    paymentDate: paymentDate,
                    note: noteController.text.isEmpty ? null : noteController.text,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _deletePurchase(Purchase purchase) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deletePurchaseTitle,
      message: l10n.deletePurchaseMessage,
      confirmLabel: l10n.delete,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_outline,
    );
    if (confirmed) {
      await _purchaseRepo.deletePurchase(purchase.id);
      _load();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final supplier = _supplier;
    if (supplier == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.supplierDetailFallbackTitle)),
        body: Center(child: Text(l10n.supplierNoLongerExists)),
      );
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(supplier.name), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 800;
                final left = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Panel(
                      title: l10n.supplierInfoPanel,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                _InfoField(l10n.colLocation, supplier.location ?? '—'),
                                _InfoField(l10n.colPhone, supplier.phone ?? '—'),
                                _InfoField(l10n.colNote, supplier.note ?? '—'),
                                _InfoField(l10n.purchasesLabel, '${_purchases.length}'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _HighlightBox(l10n.statTotalPurchased, formatMoney(_totalPurchased)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _HighlightBox(
                                    l10n.remainingOwedLabel,
                                    formatBalance(_owed).$1,
                                    color: formatBalance(_owed).$2 || _owed == 0
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFE4572E),
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
                      title: l10n.purchaseHistoryPanel,
                      description: l10n.mostRecentFirst,
                      child: _purchases.isEmpty
                          ? EmptyState(icon: Icons.shopping_cart_outlined, title: l10n.noPurchasesYet)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      columns: [
                                        DataColumn(label: Text(l10n.colDate)),
                                        DataColumn(label: Text(l10n.colItems), numeric: true),
                                        DataColumn(label: Text(l10n.totalLabel), numeric: true),
                                        DataColumn(label: Text(l10n.colPaid), numeric: true),
                                        DataColumn(label: Text(l10n.colRemaining), numeric: true),
                                        DataColumn(label: Text(l10n.colActions)),
                                      ],
                                      rows: _purchases.map((p) {
                                        final remaining = p.totalAmount - p.amountPaid;
                                        return DataRow(
                                          onSelectChanged: (_) => _editPurchase(p),
                                          cells: [
                                            DataCell(Text(_formatDate(p.purchaseDate))),
                                            DataCell(Text('${_itemCounts[p.id] ?? 0}')),
                                            DataCell(
                                              Text(
                                                formatMoney(p.totalAmount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0E7C7B),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(formatMoney(p.amountPaid))),
                                            DataCell(
                                              Text(
                                                formatMoney(remaining),
                                                style: TextStyle(
                                                  color: remaining > 0
                                                      ? const Color(0xFFE4572E)
                                                      : const Color(0xFF16A34A),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                                                    tooltip: l10n.viewAction,
                                                    onPressed: () => Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => PurchaseReceiptScreen(db: widget.db, purchaseId: p.id),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                                    tooltip: l10n.editPurchaseTooltip,
                                                    onPressed: () => _editPurchase(p),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                                                    onPressed: () => _deletePurchase(p),
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
                    const SizedBox(height: 20),
                    Panel(
                      title: l10n.paymentsHistoryPanel,
                      description: l10n.paymentCountDesc(_payments.length),
                      child: _payments.isEmpty
                          ? EmptyState(icon: Icons.payments_outlined, title: l10n.noPaymentsYet)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text(l10n.colDate)),
                                        DataColumn(label: Text(l10n.colAmount), numeric: true),
                                        DataColumn(label: Text(l10n.colNote)),
                                      ],
                                      rows: _payments.map((p) {
                                        return DataRow(cells: [
                                          DataCell(Text(_formatDate(p.paymentDate))),
                                          DataCell(
                                            Text(
                                              formatMoney(p.amount),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF16A34A),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(p.note ?? '—')),
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

                final right = Panel(
                  title: l10n.quickActionsPanel,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _recordPayment,
                            icon: const Icon(Icons.payments_outlined),
                            label: Text(l10n.recordPaymentTitle),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _newPurchase,
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: Text(l10n.newPurchaseAction),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _editSupplier,
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFFF2A93B)),
                            label: Text(l10n.editSupplier, style: const TextStyle(color: Color(0xFFF2A93B))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF2A93B))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: supplier.isArchived
                              ? OutlinedButton.icon(
                                  onPressed: _restoreSupplier,
                                  icon: const Icon(Icons.restore, color: Color(0xFF16A34A)),
                                  label: Text(l10n.restoreAction, style: const TextStyle(color: Color(0xFF16A34A))),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF16A34A))),
                                )
                              : OutlinedButton.icon(
                                  onPressed: _archiveSupplier,
                                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                  label: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                                  style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
                                ),
                        ),
                      ],
                    ),
                  ),
                );

                if (narrow) {
                  return Column(children: [left, const SizedBox(height: 20), right]);
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _HighlightBox(this.label, this.value, {this.color});

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
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
