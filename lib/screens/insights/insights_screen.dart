import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/insights_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/money_text.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../customers/customer_detail_screen.dart';
import '../suppliers/supplier_detail_screen.dart';

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
  List<({Customer customer, double balance, DateTime lastActivity})>
  _oldDebtCustomers = [];
  List<({Supplier supplier, double owed})> _supplierPriority = [];
  ({double nextWeekEstimate, double nextMonthEstimate})? _forecast;
  ({bool isAnomaly, bool isLow, double todayRevenue, double avgRevenue})?
  _anomaly;

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
    final oldDebtCustomers = await _repo.getOldDebtCustomers();
    final supplierPriority = await _repo.getSupplierPriorityPayments();
    if (!mounted) return;
    setState(() {
      _reorderSuggestions = reorder;
      _stagnantProducts = stagnant;
      _forecast = forecast;
      _anomaly = anomaly;
      _oldDebtCustomers = oldDebtCustomers;
      _supplierPriority = supplierPriority;
      _loading = false;
    });
  }

  Future<void> _openCustomer(int customerId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerDetailScreen(db: widget.db, customerId: customerId),
      ),
    );
    _load();
  }

  Future<void> _openSupplier(int supplierId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SupplierDetailScreen(db: widget.db, supplierId: supplierId),
      ),
    );
    _load();
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
          PageHeader(
            title: l10n.insightsTitle,
            subtitle: l10n.insightsSubtitle,
          ),
          Builder(
            builder: (context) {
              final stats = [
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
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 128,
                ),
                itemCount: stats.length,
                itemBuilder: (context, i) => stats[i],
              );
            },
          ),
          if (anomaly != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    (anomaly.isLow
                            ? const Color(0xFFE4572E)
                            : const Color(0xFF16A34A))
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      (anomaly.isLow
                              ? const Color(0xFFE4572E)
                              : const Color(0xFF16A34A))
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    anomaly.isLow ? Icons.trending_down : Icons.trending_up,
                    color: anomaly.isLow
                        ? const Color(0xFFE4572E)
                        : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      anomaly.isLow
                          ? l10n.todayAnomalyLowMessage(
                              formatMoney(anomaly.todayRevenue),
                              formatMoney(anomaly.avgRevenue),
                            )
                          : l10n.todayAnomalyHighMessage(
                              formatMoney(anomaly.todayRevenue),
                              formatMoney(anomaly.avgRevenue),
                            ),
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
                ? EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.noReorderSuggestions,
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
                                label: Text(l10n.colCurrentStock),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.colDaysLeft),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text(l10n.colSuggestedQty),
                                numeric: true,
                              ),
                              DataColumn(label: Text(l10n.colSupplier)),
                            ],
                            rows: _reorderSuggestions.map((s) {
                              return DataRow(
                                cells: [
                                  DataCell(Tooltip(
                                    message: s.productName,
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        s.productName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )),
                                  DataCell(
                                    Text(
                                      formatQuantity(
                                        s.currentStock,
                                        s.unitType,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      s.daysOfStockLeft.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: s.daysOfStockLeft < 7
                                            ? const Color(0xFFE4572E)
                                            : null,
                                        fontWeight: s.daysOfStockLeft < 7
                                            ? FontWeight.w700
                                            : null,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatQuantity(
                                        s.suggestedReorderQty,
                                        s.unitType,
                                      ),
                                    ),
                                  ),
                                  DataCell(Tooltip(
                                    message: s.suggestedSupplierName ?? '—',
                                    child: SizedBox(
                                      width: 160,
                                      child: Text(
                                        s.suggestedSupplierName ?? '—',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )),
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
            title: l10n.stagnantProductsPanel,
            description: l10n.stagnantProductsDesc,
            child: _stagnantProducts.isEmpty
                ? EmptyState(
                    icon: Icons.hourglass_empty,
                    title: l10n.noStagnantProducts,
                  )
                : Column(
                    children: _stagnantProducts.map((p) {
                      return ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(productDisplayName(p)),
                        trailing: Text(
                          formatQuantity(p.stockQuantity, p.unitType),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),
          Panel(
            title: l10n.oldDebtCustomersPanel,
            description: l10n.oldDebtCustomersDesc,
            child: _oldDebtCustomers.isEmpty
                ? EmptyState(
                    icon: Icons.person_off_outlined,
                    title: l10n.noOldDebtCustomers,
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
                              DataColumn(label: Text(l10n.colName)),
                              DataColumn(
                                label: Text(l10n.colBalance),
                                numeric: true,
                              ),
                              DataColumn(label: Text(l10n.lastActivityLabel)),
                            ],
                            rows: _oldDebtCustomers.map((entry) {
                              return DataRow(
                                onSelectChanged: (_) =>
                                    _openCustomer(entry.customer.id),
                                cells: [
                                  DataCell(
                                    Tooltip(
                                      message: entry.customer.name,
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          entry.customer.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    MoneyText(
                                      formatMoney(entry.balance),
                                      style: const TextStyle(
                                        color: Color(0xFFE4572E),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      l10n.daysAgo(
                                        DateTime.now()
                                            .difference(entry.lastActivity)
                                            .inDays,
                                      ),
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
            title: l10n.supplierPriorityPanel,
            description: l10n.supplierPriorityDesc,
            child: _supplierPriority.isEmpty
                ? EmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.noSupplierPriority,
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
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: Text(l10n.colSupplier)),
                              DataColumn(
                                label: Text(l10n.colOwed),
                                numeric: true,
                              ),
                            ],
                            rows: _supplierPriority.map((entry) {
                              return DataRow(
                                onSelectChanged: (_) =>
                                    _openSupplier(entry.supplier.id),
                                cells: [
                                  DataCell(
                                    Tooltip(
                                      message: entry.supplier.name,
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          entry.supplier.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    MoneyText(
                                      formatMoney(entry.owed),
                                      style: const TextStyle(
                                        color: Color(0xFFE4572E),
                                        fontWeight: FontWeight.w700,
                                      ),
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
      ),
    );
  }
}
