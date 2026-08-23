import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/database/database.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';

class InvoiceViewScreen extends StatefulWidget {
  final AppDatabase db;
  final int saleId;
  const InvoiceViewScreen({super.key, required this.db, required this.saleId});

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  late final SalesRepository _salesRepo = SalesRepository(widget.db);
  late final CustomerRepository _customerRepo = CustomerRepository(widget.db);
  late final SettingsRepository _settingsRepo = SettingsRepository(widget.db);

  bool _loading = true;
  Sale? _sale;
  List<SaleItem> _items = [];
  Map<int, Product> _products = {};
  Customer? _customer;
  String _shopName = 'Nova Pro';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sale = await _salesRepo.getSaleById(widget.saleId);
    final items = await _salesRepo.getItemsForSale(widget.saleId);
    final products = <int, Product>{};
    for (final item in items) {
      products[item.productId] = await _salesRepo.getProduct(item.productId);
    }
    Customer? customer;
    if (sale.customerId != null) {
      customer = await _customerRepo.getById(sale.customerId!);
    }
    final settings = await _settingsRepo.getSettings();
    if (!mounted) return;
    setState(() {
      _sale = sale;
      _items = items;
      _products = products;
      _customer = customer;
      _shopName = settings.shopName;
      _loading = false;
    });
  }

  Future<void> _printInvoice() async {
    final doc = pw.Document();
    final sale = _sale!;
    final remaining = sale.totalAmount - sale.amountPaid;
    final dateStr = sale.date.toString().split(' ').first;
    final customerName = _customer?.name ?? 'Walk-in Customer';

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
                pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
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
                    pw.Text('BILL TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _pdfMuted)),
                    pw.SizedBox(height: 3),
                    pw.Text(customerName, style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(children: [
                      pw.Text('Invoice #  ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _pdfMuted)),
                      pw.Text('INV-${sale.id}', style: const pw.TextStyle(fontSize: 9)),
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
              headers: ['QTY', 'DESCRIPTION', 'UNIT PRICE', 'AMOUNT'],
              data: _items.map((item) {
                final product = _products[item.productId];
                return [
                  '${item.quantity}',
                  product?.name ?? 'Unknown',
                  formatMoney(item.unitPrice),
                  formatMoney(item.quantity * item.unitPrice),
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
                    pdfTotalsRow('Total', formatMoney(sale.totalAmount)),
                    pw.SizedBox(height: 6),
                    pdfTotalsRow('Paid', formatMoney(sale.amountPaid)),
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
              child: pw.Text('Thank you for your business', style: pw.TextStyle(fontSize: 9, color: _pdfMuted)),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final sale = _sale!;
    final remaining = sale.totalAmount - sale.amountPaid;
    final dateStr = sale.date.toString().split(' ').first;
    final customerName = _customer?.name ?? 'Walk-in Customer';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceHashTitle('${sale.id}')),
        leading: const BackButton(),
        actions: [
          IconButton(onPressed: _printInvoice, icon: const Icon(Icons.print_outlined), tooltip: l10n.printSavePdfTooltip),
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
                      const Text('INVOICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          Text('BILL TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 4),
                          Text(customerName, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: [
                            Text('Invoice #  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            Text('INV-${sale.id}', style: const TextStyle(fontSize: 11)),
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
                          _Cell('UNIT PRICE', bold: true, align: TextAlign.right),
                          _Cell('AMOUNT', bold: true, align: TextAlign.right),
                        ],
                      ),
                      ..._items.map((item) {
                        final product = _products[item.productId];
                        return TableRow(children: [
                          _Cell('${item.quantity}'),
                          _Cell(product?.name ?? l10n.unknownProductLabel),
                          _Cell(formatMoney(item.unitPrice), align: TextAlign.right),
                          _Cell(formatMoney(item.quantity * item.unitPrice), align: TextAlign.right),
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
                          _totalsRow('Total', formatMoney(sale.totalAmount)),
                          const SizedBox(height: 6),
                          _totalsRow('Paid', formatMoney(sale.amountPaid)),
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
                    child: Text('Thank you for your business', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
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
