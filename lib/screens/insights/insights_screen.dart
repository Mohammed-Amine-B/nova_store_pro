import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/insights_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';

class InsightsScreen extends StatefulWidget {
  final AppDatabase db;
  const InsightsScreen({super.key, required this.db});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final InsightsRepository _repo = InsightsRepository(widget.db);

  bool _loading = true;
  List<ReorderSuggestion> _reorderSuggestions = [];
  List<Product> _stagnantProducts = [];
  ({double nextWeekEstimate, double nextMonthEstimate})? _forecast;
  ({bool isAnomaly, bool isLow, double todayRevenue, double avgRevenue})? _anomaly;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reorder = await _repo.getReorderSuggestions();
    final stagnant = await _repo.getStagnantProducts();
    final forecast = await _repo.getSalesForecast();
    final anomaly = await _repo.getTodayAnomaly();
    if (!mounted) return;
    setState(() {
      _reorderSuggestions = reorder;
      _stagnantProducts = stagnant;
      _forecast = forecast;
      _anomaly = anomaly;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    final forecast = _forecast;
    final anomaly = _anomaly;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: l10n.insightsTitle, subtitle: l10n.insightsSubtitle),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.6,
            children: [
              StatCard(
                label: l10n.statNextWeekEstimate,
                value: formatMoney(forecast?.nextWeekEstimate ?? 0),
                icon: Icons.auto_graph,
                accentColor: const Color(0xFF0E7C7B),
              ),
              StatCard(
                label: l10n.statNextMonthEstimate,
                value: formatMoney(forecast?.nextMonthEstimate ?? 0),
                icon: Icons.insights_outlined,
                accentColor: const Color(0xFFF2A93B),
              ),
            ],
          ),
          if (anomaly != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (anomaly.isLow ? const Color(0xFFE4572E) : const Color(0xFF16A34A)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (anomaly.isLow ? const Color(0xFFE4572E) : const Color(0xFF16A34A)).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    anomaly.isLow ? Icons.trending_down : Icons.trending_up,
                    color: anomaly.isLow ? const Color(0xFFE4572E) : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      anomaly.isLow
                          ? l10n.todayAnomalyLowMessage(formatMoney(anomaly.todayRevenue), formatMoney(anomaly.avgRevenue))
                          : l10n.todayAnomalyHighMessage(formatMoney(anomaly.todayRevenue), formatMoney(anomaly.avgRevenue)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Panel(
            title: l10n.reorderSuggestionsPanel,
            description: l10n.reorderSuggestionsDesc,
            child: _reorderSuggestions.isEmpty
                ? EmptyState(icon: Icons.inventory_2_outlined, title: l10n.noReorderSuggestions)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text(l10n.colProduct)),
                              DataColumn(label: Text(l10n.colCurrentStock), numeric: true),
                              DataColumn(label: Text(l10n.colDaysLeft), numeric: true),
                              DataColumn(label: Text(l10n.colSuggestedQty), numeric: true),
                              DataColumn(label: Text(l10n.colSupplier)),
                            ],
                            rows: _reorderSuggestions.map((s) {
                              return DataRow(cells: [
                                DataCell(Text(s.productName)),
                                DataCell(Text(formatQuantity(s.currentStock, s.unitType))),
                                DataCell(Text(
                                  s.daysOfStockLeft.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: s.daysOfStockLeft < 7 ? const Color(0xFFE4572E) : null,
                                    fontWeight: s.daysOfStockLeft < 7 ? FontWeight.w700 : null,
                                  ),
                                )),
                                DataCell(Text(formatQuantity(s.suggestedReorderQty, s.unitType))),
                                DataCell(Text(s.suggestedSupplierName ?? '—')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.stagnantProductsPanel,
            description: l10n.stagnantProductsDesc,
            child: _stagnantProducts.isEmpty
                ? EmptyState(icon: Icons.hourglass_empty, title: l10n.noStagnantProducts)
                : Column(
                    children: _stagnantProducts.map((p) {
                      return ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(productDisplayName(p)),
                        trailing: Text(
                          formatQuantity(p.stockQuantity, p.unitType),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
