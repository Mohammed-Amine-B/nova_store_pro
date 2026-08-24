import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatting.dart';
import 'sales_day_detail_screen.dart';
import '../reports/invoice_view_screen.dart';
import '../suppliers/purchase_receipt_screen.dart';
import '../../widgets/return_dialog.dart';

enum ArchiveView { todaySales, customerSales, supplierPurchases }

class ArchiveScreen extends StatefulWidget {
  final AppDatabase db;
  const ArchiveScreen({super.key, required this.db});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late final SalesRepository _repo = SalesRepository(widget.db);
  late final PurchaseRepository _purchaseRepo = PurchaseRepository(widget.db);
  ArchiveView _view = ArchiveView.todaySales;

  late Future<List<({DateTime date, double revenue, double profit, int count})>> _daysFuture;
  late Future<List<({Sale sale, String customerName})>> _invoicesFuture;
  late Future<List<({Purchase purchase, String supplierName})>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _daysFuture = _repo.getArchiveDays();
    _invoicesFuture = _repo.getCustomerSaleInvoices();
    _purchasesFuture = _purchaseRepo.getAllPurchaseRecords();
  }

  void _reload() {
    setState(_loadAll);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _openDay(DateTime date) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SalesDayDetailScreen(db: widget.db, date: date),
      ),
    );
    _reload();
  }

  Future<void> _openInvoice(int saleId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => InvoiceViewScreen(db: widget.db, saleId: saleId)),
    );
  }

  Future<void> _openReceipt(int purchaseId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PurchaseReceiptScreen(db: widget.db, purchaseId: purchaseId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: l10n.archiveTitle, subtitle: l10n.archiveSubtitle),
          SegmentedButton<ArchiveView>(
            segments: [
              ButtonSegment(value: ArchiveView.todaySales, label: Text(l10n.navTodaySales), icon: const Icon(Icons.point_of_sale_outlined)),
              ButtonSegment(value: ArchiveView.customerSales, label: Text(l10n.customerSalesLabel), icon: const Icon(Icons.receipt_long_outlined)),
              ButtonSegment(value: ArchiveView.supplierPurchases, label: Text(l10n.supplierPurchasesLabel), icon: const Icon(Icons.local_shipping_outlined)),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
          const SizedBox(height: 20),
          if (_view == ArchiveView.todaySales)
            FutureBuilder<List<({DateTime date, double revenue, double profit, int count})>>(
              future: _daysFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final days = snapshot.data!;
                return Panel(
                  title: l10n.salesHistoryPanel,
                  description: l10n.daysRecorded(days.length),
                  child: days.isEmpty
                      ? EmptyState(icon: Icons.archive_outlined, title: l10n.noArchivedDaysYet)
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
                                    DataColumn(label: Text(l10n.statRevenue), numeric: true),
                                    DataColumn(label: Text(l10n.statProfit), numeric: true),
                                    DataColumn(label: Text(l10n.colSalesCount), numeric: true),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: days.map((d) {
                                    return DataRow(
                                      onSelectChanged: (_) => _openDay(d.date),
                                      cells: [
                                        DataCell(Text(_formatDate(d.date))),
                                        DataCell(Text(formatMoney(d.revenue))),
                                        DataCell(Text(formatMoney(d.profit), style: const TextStyle(color: Colors.green))),
                                        DataCell(Text('${d.count}')),
                                        DataCell(TextButton.icon(
                                          onPressed: () => _openDay(d.date),
                                          icon: const Icon(Icons.chevron_right, size: 16),
                                          label: Text(l10n.openAction),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            )
          else if (_view == ArchiveView.customerSales)
            FutureBuilder<List<({Sale sale, String customerName})>>(
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final invoices = snapshot.data!;
                return Panel(
                  title: l10n.customerSalesLabel,
                  description: l10n.invoiceCountDesc(invoices.length),
                  child: invoices.isEmpty
                      ? EmptyState(icon: Icons.receipt_long_outlined, title: l10n.noCustomerSalesYet)
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
                                    DataColumn(label: Text(l10n.colCustomer)),
                                    DataColumn(label: Text(l10n.totalLabel), numeric: true),
                                    DataColumn(label: Text(l10n.colPaid), numeric: true),
                                    DataColumn(label: Text(l10n.colRemaining), numeric: true),
                                    DataColumn(label: Text(l10n.colMethod)),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: invoices.map((entry) {
                                    final s = entry.sale;
                                    final remaining = s.totalAmount - s.amountPaid;
                                    final tone = switch (s.paymentMethod) {
                                      'cash' => BadgeTone.success,
                                      'card' => BadgeTone.neutral,
                                      'credit' => BadgeTone.destructive,
                                      'split' => BadgeTone.warning,
                                      _ => BadgeTone.neutral,
                                    };
                                    return DataRow(
                                      onSelectChanged: (_) => _openInvoice(s.id),
                                      cells: [
                                        DataCell(Text(_formatDate(s.date))),
                                        DataCell(Text(entry.customerName)),
                                        DataCell(Text(formatMoney(s.totalAmount))),
                                        DataCell(Text(formatMoney(s.amountPaid))),
                                        DataCell(Text(
                                          formatMoney(remaining),
                                          style: TextStyle(
                                            color: remaining > 0 ? const Color(0xFFE4572E) : const Color(0xFF16A34A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )),
                                        DataCell(StatusBadge(label: s.paymentMethod, tone: tone)),
                                                                                DataCell(Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () => _openInvoice(s.id),
                                              icon: const Icon(Icons.receipt_long_outlined, size: 16),
                                              label: Text(l10n.invoiceAction),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.assignment_return_outlined, size: 18),
                                              tooltip: l10n.returnTooltip,
                                              onPressed: () async {
                                                await showReturnDialog(context, widget.db, s.id);
                                                _reload();
                                              },
                                            ),
                                          ],
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            )
          else
            FutureBuilder<List<({Purchase purchase, String supplierName})>>(
              future: _purchasesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final purchases = snapshot.data!;
                return Panel(
                  title: l10n.supplierPurchasesLabel,
                  description: l10n.purchaseCountDesc(purchases.length),
                  child: purchases.isEmpty
                      ? EmptyState(icon: Icons.local_shipping_outlined, title: l10n.noSupplierPurchasesYet)
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
                                    DataColumn(label: Text(l10n.colSupplier)),
                                    DataColumn(label: Text(l10n.totalLabel), numeric: true),
                                    DataColumn(label: Text(l10n.colPaid), numeric: true),
                                    DataColumn(label: Text(l10n.colRemaining), numeric: true),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: purchases.map((entry) {
                                    final p = entry.purchase;
                                    final remaining = p.totalAmount - p.amountPaid;
                                    return DataRow(
                                      onSelectChanged: (_) => _openReceipt(p.id),
                                      cells: [
                                        DataCell(Text(_formatDate(p.purchaseDate))),
                                        DataCell(Text(entry.supplierName)),
                                        DataCell(Text(formatMoney(p.totalAmount))),
                                        DataCell(Text(formatMoney(p.amountPaid))),
                                        DataCell(Text(
                                          formatMoney(remaining),
                                          style: TextStyle(
                                            color: remaining > 0 ? const Color(0xFFE4572E) : const Color(0xFF16A34A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )),
                                        DataCell(IconButton(
                                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                                          tooltip: l10n.viewAction,
                                          onPressed: () => _openReceipt(p.id),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}
