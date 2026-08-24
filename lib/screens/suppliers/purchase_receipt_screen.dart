import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/database/database.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../utils/formatting.dart';

class PurchaseReceiptScreen extends StatefulWidget {
  final AppDatabase db;
  final int purchaseId;
  const PurchaseReceiptScreen({super.key, required this.db, required this.purchaseId});

  @override
  State<PurchaseReceiptScreen> createState() => _PurchaseReceiptScreenState();
}

class _PurchaseReceiptScreenState extends State<PurchaseReceiptScreen> {
  late final PurchaseRepository _purchaseRepo = PurchaseRepository(widget.db);
  late final SupplierRepository _supplierRepo = SupplierRepository(widget.db);
  late final ProductRepository _productRepo = ProductRepository(widget.db);
  late final SettingsRepository _settingsRepo = SettingsRepository(widget.db);

  bool _loading = true;
  Purchase? _purchase;
  List<PurchaseItem> _items = [];
  Map<int, Product> _products = {};
  Supplier? _supplier;
  String _shopName = 'Nova Pro';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final purchase = await _purchaseRepo.getPurchaseById(widget.purchaseId);
    final items = await _purchaseRepo.getPurchaseItems(widget.purchaseId);
    final products = <int, Product>{};
    for (final item in items) {
      final product = await _productRepo.getById(item.productId);
      if (product != null) products[item.productId] = product;
    }
    final supplier = await _supplierRepo.getById(purchase.supplierId);
    final settings = await _settingsRepo.getSettings();
    if (!mounted) return;
    setState(() {
      _purchase = purchase;
      _items = items;
      _products = products;
      _supplier = supplier;
      _shopName = settings.shopName;
      _loading = false;
    });
  }

  Future<void> _printReceipt() async {
    final doc = pw.Document();
    final purchase = _purchase!;
    final remaining = purchase.totalAmount - purchase.amountPaid;
    final dateStr = purchase.purchaseDate.toString().split(' ').first;
    final supplierName = _supplier?.name ?? 'Unknown Supplier';

    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_shopName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('PURCHASE RECEIPT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 28),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SUPPLIER', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _pdfMuted)),
                    pw.SizedBox(height: 3),
                    pw.Text(supplierName, style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(children: [
                      pw.Text('Receipt #  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _pdfMuted)),
                      pw.Text('PR-${purchase.id}', style: const pw.TextStyle(fontSize: 9)),
                    ]),
                    pw.SizedBox(height: 3),
                    pw.Row(children: [
                      pw.Text('Date  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _pdfMuted)),
                      pw.Text(dateStr, style: const pw.TextStyle(fontSize: 9)),
                    ]),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.TableHelper.fromTextArray(
              headers: ['QTY', 'DESCRIPTION', 'BUY PRICE', 'AMOUNT'],
              data: _items.map((item) {
                final product = _products[item.productId];
                return [
                  '${item.quantity}',
                  product != null ? productDisplayName(product) : 'Unknown',
                  formatMoney(item.buyPrice),
                  formatMoney(item.quantity * item.buyPrice),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: _pdfHeaderBg),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: pw.TableBorder.all(color: _pdfBorder, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
              },
              cellAlignments: const {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
              headerAlignments: const {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.SizedBox(
                width: 260,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pdfTotalsRow('Total', formatMoney(purchase.totalAmount)),
                    pw.SizedBox(height: 6),
                    pdfTotalsRow('Paid', formatMoney(purchase.amountPaid)),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      color: _pdfHeaderBg,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: remaining > 0
                          ? pdfTotalsRow('Remaining', formatMoney(remaining), bold: true, color: _pdfTerracotta)
                          : pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Text('Paid in Full', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _pdfSuccess)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Spacer(),
            pw.Center(
              child: pw.Text('Recorded for accounting purposes', style: pw.TextStyle(fontSize: 9, color: _pdfMuted)),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final purchase = _purchase!;
    final remaining = purchase.totalAmount - purchase.amountPaid;
    final dateStr = purchase.purchaseDate.toString().split(' ').first;
    final supplierName = _supplier?.name ?? 'Unknown Supplier';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt #${purchase.id}'),
        leading: const BackButton(),
        actions: [
          IconButton(onPressed: _printReceipt, icon: const Icon(Icons.print_outlined), tooltip: 'Print / Save PDF'),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('PURCHASE RECEIPT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUPPLIER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 4),
                          Text(supplierName, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: [
                            Text('Receipt #  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            Text('PR-${purchase.id}', style: const TextStyle(fontSize: 11)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text('Date  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            Text(dateStr, style: const TextStyle(fontSize: 11)),
                          ]),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Table(
                    border: TableBorder.all(color: theme.dividerColor, width: 0.5),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.06)),
                        children: [
                          _Cell('QTY', bold: true),
                          _Cell('DESCRIPTION', bold: true),
                          _Cell('BUY PRICE', bold: true, align: TextAlign.right),
                          _Cell('AMOUNT', bold: true, align: TextAlign.right),
                        ],
                      ),
                      ..._items.map((item) {
                        final product = _products[item.productId];
                        return TableRow(children: [
                          _Cell('${item.quantity}'),
                          _Cell(product != null ? productDisplayName(product) : 'Unknown'),
                          _Cell(formatMoney(item.buyPrice), align: TextAlign.right),
                          _Cell(formatMoney(item.quantity * item.buyPrice), align: TextAlign.right),
                        ]);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 280,
                      child: Column(
                        children: [
                          _totalsRow('Total', formatMoney(purchase.totalAmount)),
                          const SizedBox(height: 6),
                          _totalsRow('Paid', formatMoney(purchase.amountPaid)),
                          const SizedBox(height: 6),
                          Container(
                            color: theme.colorScheme.primary.withValues(alpha: 0.06),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: remaining > 0
                                ? _totalsRow('Remaining', formatMoney(remaining), bold: true, color: const Color(0xFFE4572E))
                                : const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('Paid in Full', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text('Recorded for accounting purposes', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _totalsRow(String label, String value, {bool bold = false, Color? color}) {
  final style = TextStyle(
    fontSize: bold ? 13 : 12,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    color: color,
  );
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: style),
      Text(value, style: style),
    ],
  );
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  final TextAlign align;
  const _Cell(this.text, {this.bold = false, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 12),
      ),
    );
  }
}

final _pdfMuted = PdfColor.fromHex('#6B7280');
final _pdfTerracotta = PdfColor.fromHex('#E4572E');
final _pdfSuccess = PdfColor.fromHex('#16A34A');
final _pdfBorder = PdfColor.fromHex('#E0E0E0');
final _pdfHeaderBg = PdfColor.fromHex('#F5F5F5');

/// A right-aligned "label: value" row used in a PDF totals block.
pw.Widget pdfTotalsRow(String label, String value, {bool bold = false, PdfColor? color}) {
  final style = pw.TextStyle(
    fontSize: bold ? 12 : 11,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: color,
  );
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text(value, style: style),
    ],
  );
}
