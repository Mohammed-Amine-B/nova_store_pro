import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/database/database.dart';
import '../../data/repositories/report_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/date_range_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/money_text.dart';
import '../../utils/formatting.dart';

enum ReportRange { today, week, month, custom }

class ReportsScreen extends StatefulWidget {
  final AppDatabase db;
  const ReportsScreen({super.key, required this.db});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportRepository _repo = ReportRepository(widget.db);
  ReportRange _range = ReportRange.week;
  DateTimeRange? _customRange;

  List<DailyPoint> _series = [];
  List<BestSellingProduct> _bestSellers = [];
  double _stockValue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  (DateTime, DateTime) _resolveRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case ReportRange.today:
        return (today, today.add(const Duration(days: 1)));
      case ReportRange.week:
        return (
          today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)),
        );
      case ReportRange.month:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        );
      case ReportRange.custom:
        if (_customRange == null)
          return (today, today.add(const Duration(days: 1)));
        return (
          _customRange!.start,
          _customRange!.end.add(const Duration(days: 1)),
        );
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (start, end) = _resolveRange();
    final series = await _repo.getDailySeries(start, end);
    final bestSellers = await _repo.getBestSellingProducts(start, end);
    final stockValue = await _repo.getCurrentStockValue();
    if (!mounted) return;
    setState(() {
      _series = series;
      _bestSellers = bestSellers;
      _stockValue = stockValue;
      _loading = false;
    });
  }

  Future<void> _pickCustomRange() async {
    final picked = await showCustomDateRangeDialog(
      context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _range = ReportRange.custom;
        _customRange = picked;
      });
      _load();
    }
  }

  double get _totalRevenue => _series.fold(0, (sum, p) => sum + p.revenue);
  double get _totalProfit => _series.fold(0, (sum, p) => sum + p.profit);

  String _csvContent() {
    final buffer = StringBuffer();
    buffer.writeln('Date,Revenue,Profit');
    for (final point in _series) {
      buffer.writeln(
        '${point.date.toIso8601String().split('T').first},${point.revenue},${point.profit}',
      );
    }
    buffer.writeln();
    buffer.writeln('Product,Units Sold,Revenue');
    for (final p in _bestSellers) {
      buffer.writeln('"${p.productName}",${p.unitsSold},${p.revenue}');
    }
    return buffer.toString();
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context)!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/nova_pro_report_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(_csvContent());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.csvSavedMessage(file.path))));
  }

  Future<void> _exportPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sales Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Total Revenue: ${formatMoney(_totalRevenue)}'),
            pw.Text('Total Profit: ${formatMoney(_totalProfit)}'),
            pw.SizedBox(height: 16),
            pw.Text(
              'Best Selling Products',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Product', 'Units Sold', 'Revenue'],
              data: _bestSellers
                  .map(
                    (p) => [
                      p.productName,
                      p.unitsSold.toString(),
                      formatMoney(p.revenue),
                    ],
                  )
                  .toList(),
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    final maxY = _series.isEmpty
        ? 100.0
        : _series.map((p) => p.revenue).reduce((a, b) => a > b ? a : b) * 1.2;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.reportsTitle,
            subtitle: l10n.reportsSubtitle,
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.download),
                  label: Text(l10n.csvExportAction),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(l10n.pdfExportAction),
                ),
              ],
            ),
          ),
          SegmentedButton<ReportRange>(
            segments: [
              ButtonSegment(
                value: ReportRange.today,
                label: Text(l10n.rangeToday),
              ),
              ButtonSegment(
                value: ReportRange.week,
                label: Text(l10n.rangeWeek),
              ),
              ButtonSegment(
                value: ReportRange.month,
                label: Text(l10n.rangeMonth),
              ),
              ButtonSegment(
                value: ReportRange.custom,
                label: Text(l10n.rangeCustom),
              ),
            ],
            selected: {_range},
            onSelectionChanged: (s) {
              if (s.first == ReportRange.custom) {
                _pickCustomRange();
              } else {
                setState(() => _range = s.first);
                _load();
              }
            },
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              final stats = [
                StatCard(
                  label: l10n.statRevenue,
                  value: formatMoney(_totalRevenue),
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: const Color(0xFF0E7C7B),
                ),
                StatCard(
                  label: l10n.statProfit,
                  value: formatMoney(_totalProfit),
                  icon: Icons.trending_up,
                  accentColor: const Color(0xFF16A34A),
                ),
                StatCard(
                  label: l10n.statStockValue,
                  value: formatMoney(_stockValue),
                  icon: Icons.inventory_2_outlined,
                  accentColor: const Color(0xFFF2A93B),
                ),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 128,
                ),
                itemCount: stats.length,
                itemBuilder: (context, i) => stats[i],
              );
            },
          ),
          const SizedBox(height: 24),
          Panel(
            title: l10n.revenueTrendPanel,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 220,
                child: _series.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: Icons.bar_chart_outlined,
                          title: l10n.noSalesInRange,
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          maxY: maxY,
                          barGroups: _series.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.revenue,
                                  color: const Color(0xFF0E7C7B),
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= _series.length)
                                    return const SizedBox.shrink();
                                  final d = _series[i].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${d.month}/${d.day}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.bestSellingProductsPanel,
            child: _bestSellers.isEmpty
                ? EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: l10n.noSalesInRange,
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
                                label: Text(l10n.colUnitsSold),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.statRevenue),
                                numeric: true,
                              ),
                            ],
                            rows: _bestSellers.map((p) {
                              return DataRow(
                                cells: [
                                  DataCell(Tooltip(
                                    message: p.productName,
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        p.productName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )),
                                  DataCell(Text('${p.unitsSold}')),
                                  DataCell(MoneyText(formatMoney(p.revenue))),
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
      ),
    );
  }
}
