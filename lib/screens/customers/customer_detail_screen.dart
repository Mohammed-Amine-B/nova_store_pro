import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/panel.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/enter_to_submit.dart';
import '../../widgets/money_text.dart';
import '../../utils/formatting.dart';
import 'customer_form_dialog.dart';
import 'customer_sale_screen.dart';
import '../reports/invoice_view_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final AppDatabase db;
  final int customerId;
  const CustomerDetailScreen({
    super.key,
    required this.db,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomerRepository _repo = CustomerRepository(widget.db);
  late final SalesRepository _salesRepo = SalesRepository(widget.db);

  Customer? _customer;
  Map<int, List<SaleItem>> _itemsBySale = {};
  List<_HistoryEntry> _history = [];
  double _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customer = await _repo.getById(widget.customerId);
    final sales = await _repo.getSalesForCustomer(widget.customerId);
    final itemsBySale = <int, List<SaleItem>>{};
    for (final s in sales) {
      itemsBySale[s.id] = await _salesRepo.getItemsForSale(s.id);
    }
    final payments = await _repo.getPaymentsForCustomer(widget.customerId);
    final debtAdjustments = await _repo.getDebtAdjustments(widget.customerId);
    final balance = await _repo.getRemainingBalance(widget.customerId);

    final history = <_HistoryEntry>[
      ...sales.map((s) => _HistoryEntry.sale(s)),
      ...payments.map((p) => _HistoryEntry.payment(p)),
      ...debtAdjustments.map((a) => _HistoryEntry.debt(a)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;
    setState(() {
      _customer = customer;
      _itemsBySale = itemsBySale;
      _history = history;
      _balance = balance;
      _loading = false;
    });
  }

  Future<void> _editCustomer() async {
    final saved = await showDialog<int>(
      context: context,
      builder: (context) => CustomerFormDialog(repo: _repo, editing: _customer),
    );
    if (saved != null) _load();
  }

  Future<void> _archiveCustomer() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.removeCustomerTitle,
      message: l10n.removeCustomerMessage(_customer!.name),
      confirmLabel: l10n.removeAction,
      tone: ConfirmTone.destructive,
      icon: Icons.archive_outlined,
    );
    if (confirmed) {
      await _repo.archive(_customer!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _restoreCustomer() async {
    await _repo.unarchive(_customer!.id);
    _load();
  }

  Future<void> _newSale() async {
    final l10n = AppLocalizations.of(context)!;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.newSaleAction),
            leading: const BackButton(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomerSaleScreen(db: widget.db, customerId: _customer!.id),
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
          Future<void> confirm() async {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (amount <= 0) {
              setDialogState(() => error = l10n.enterValidAmount);
              return;
            }
            if (amount > _balance) {
              setDialogState(() => error = l10n.amountPaidExceedsTotal);
              return;
            }
            await _repo.recordPayment(
              customerId: _customer!.id,
              amount: amount,
              paymentDate: paymentDate,
              note: noteController.text.isEmpty ? null : noteController.text,
            );
            if (context.mounted) Navigator.pop(context, true);
          }

          return EnterToSubmit(
            onSubmit: confirm,
            child: AlertDialog(
              title: Text(l10n.recordPaymentTitle),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error != null) ...[
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: l10n.amountLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                          if (picked != null)
                            setDialogState(() => paymentDate = picked);
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(onPressed: confirm, child: Text(l10n.save)),
              ],
            ),
          );
        },
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _addDebt() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    var debtDate = DateTime.now();
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          Future<void> confirm() async {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (amount <= 0) {
              setDialogState(() => error = l10n.enterValidAmount);
              return;
            }
            await _repo.addDebtAdjustment(
              customerId: _customer!.id,
              amount: amount,
              date: debtDate,
              note: noteController.text.isEmpty ? null : noteController.text,
            );
            if (context.mounted) Navigator.pop(context, true);
          }

          return EnterToSubmit(
            onSubmit: confirm,
            child: AlertDialog(
              title: Text(l10n.addDebtAction),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error != null) ...[
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: l10n.amountLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: debtDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => debtDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.paymentDateLabel,
                            border: const OutlineInputBorder(),
                          ),
                          child: Text(
                            '${debtDate.year}-${debtDate.month.toString().padLeft(2, '0')}-${debtDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: noteController,
                        decoration: InputDecoration(
                          labelText: l10n.noteOptionalLabel,
                          hintText: l10n.debtNoteHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0E7C7B),
                  ),
                  onPressed: confirm,
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _viewInvoice(Sale sale) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceViewScreen(db: widget.db, saleId: sale.id),
      ),
    );
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
      await _salesRepo.deleteSale(sale.id);
      _load();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _buildHistoryRow(BuildContext context, _HistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return switch (entry.type) {
      _HistoryType.sale => _buildSaleHistoryRow(l10n, theme, entry.sale!),
      _HistoryType.payment => _buildPaymentHistoryRow(l10n, entry.payment!),
      _HistoryType.debt => _buildDebtHistoryRow(l10n, entry.adjustment!),
    };
  }

  Widget _buildSaleHistoryRow(AppLocalizations l10n, ThemeData theme, Sale s) {
    final items = _itemsBySale[s.id] ?? <SaleItem>[];
    final remaining = s.totalAmount - s.amountPaid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 92, child: Text(_formatDate(s.date))),
          _TypeBadge(label: l10n.catSale, color: const Color(0xFF0E7C7B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${l10n.saleItemsCount(items.length)} · ${l10n.colPaid}: ${formatMoney(s.amountPaid)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyText(
                formatMoney(s.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              MoneyText(
                remaining > 0
                    ? '${l10n.colRemaining}: ${formatMoney(remaining)}'
                    : l10n.colPaid,
                style: TextStyle(
                  fontSize: 12,
                  color: remaining > 0
                      ? const Color(0xFFE4572E)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: l10n.editSaleTitle,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(l10n.editSaleTitle),
                          leading: const BackButton(),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(24),
                          child: CustomerSaleScreen(
                            db: widget.db,
                            saleId: s.id,
                          ),
                        ),
                      ),
                    ),
                  );
                  _load();
                },
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                tooltip: l10n.viewInvoiceTooltip,
                onPressed: () => _viewInvoice(s),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => _deleteSale(s),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryRow(AppLocalizations l10n, DebtPayment p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 92, child: Text(_formatDate(p.paymentDate))),
          _TypeBadge(label: l10n.catPayment, color: const Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.note ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          MoneyText(
            '+${formatMoney(p.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDebtHistoryRow(AppLocalizations l10n, CustomerDebtAdjustment a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 92, child: Text(_formatDate(a.date))),
          _TypeBadge(
            label: l10n.debtAddedLabel,
            color: const Color(0xFFE4572E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              a.note ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          MoneyText(
            '+${formatMoney(a.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFE4572E),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.customerDetailFallbackTitle)),
        body: Center(child: Text(l10n.customerNoLongerExists)),
      );
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(customer.name), leading: const BackButton()),
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
                      title: l10n.customerInfoPanel,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                _InfoField(
                                  l10n.colPhone,
                                  customer.phone ?? '—',
                                ),
                                _InfoField(l10n.colNote, customer.note ?? '—'),
                                _InfoField(
                                  l10n.memberSinceLabel,
                                  _formatDate(customer.createdAt),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _HighlightBox(
                              l10n.remainingBalanceLabel,
                              formatBalance(_balance).$1,
                              color: formatBalance(_balance).$2 || _balance == 0
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFE4572E),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Panel(
                      title: l10n.historyPanel,
                      description: l10n.historyCountDesc(_history.length),
                      child: _history.isEmpty
                          ? EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: l10n.noHistoryYet,
                            )
                          : Column(
                              children: [
                                for (var i = 0; i < _history.length; i++) ...[
                                  _buildHistoryRow(context, _history[i]),
                                  if (i < _history.length - 1)
                                    Divider(
                                      height: 1,
                                      color: theme.dividerColor,
                                    ),
                                ],
                              ],
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
                            onPressed: _addDebt,
                            icon: const Icon(
                              Icons.add_card_outlined,
                              color: Color(0xFF0E7C7B),
                            ),
                            label: Text(
                              l10n.addDebtAction,
                              style: const TextStyle(color: Color(0xFF0E7C7B)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0E7C7B)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _newSale,
                            icon: const Icon(Icons.point_of_sale),
                            label: Text(l10n.newSaleAction),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _editCustomer,
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFFF2A93B),
                            ),
                            label: Text(
                              l10n.editCustomer,
                              style: const TextStyle(color: Color(0xFFF2A93B)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF2A93B)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: customer.isArchived
                              ? OutlinedButton.icon(
                                  onPressed: _restoreCustomer,
                                  icon: const Icon(
                                    Icons.restore,
                                    color: Color(0xFF16A34A),
                                  ),
                                  label: Text(
                                    l10n.restoreAction,
                                    style: const TextStyle(
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                )
                              : OutlinedButton.icon(
                                  onPressed: _archiveCustomer,
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  label: Text(
                                    l10n.delete,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
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

enum _HistoryType { sale, payment, debt }

/// One row in the merged Sales/Payments/Debt-Adjustments history timeline.
class _HistoryEntry {
  final DateTime date;
  final _HistoryType type;
  final Sale? sale;
  final DebtPayment? payment;
  final CustomerDebtAdjustment? adjustment;

  _HistoryEntry.sale(Sale sale)
    : date = sale.date,
      type = _HistoryType.sale,
      sale = sale,
      payment = null,
      adjustment = null;

  _HistoryEntry.payment(DebtPayment payment)
    : date = payment.paymentDate,
      type = _HistoryType.payment,
      sale = null,
      payment = payment,
      adjustment = null;

  _HistoryEntry.debt(CustomerDebtAdjustment adjustment)
    : date = adjustment.date,
      type = _HistoryType.debt,
      sale = null,
      payment = null,
      adjustment = adjustment;
}

/// Small colored pill marking a history row's type (Sale/Payment/Debt
/// Added). Uses this app's exact brand hex values directly rather than the
/// shared status-badge tones, since those don't line up 1:1 with the
/// specific colors this feature calls for.
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
      width: 160,
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
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
