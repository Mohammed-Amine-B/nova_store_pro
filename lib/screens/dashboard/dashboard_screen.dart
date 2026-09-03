import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/insights_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/activity_log_formatting.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/panel.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatting.dart';
import '../activity_log/activity_log_screen.dart';
import '../insights/insights_screen.dart';
import '../customers/select_customer_dialog.dart';
import '../customers/customer_sale_screen.dart';
import '../suppliers/select_supplier_dialog.dart';
import '../suppliers/new_purchase_screen.dart';
import '../products/product_form_dialog.dart';

typedef _DashboardInsights = ({
  List<ReorderSuggestion> reorder,
  ({bool isAnomaly, bool isLow, double todayRevenue, double avgRevenue})?
  anomaly,
});

class DashboardScreen extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback? onNewSale;
  final VoidCallback? onViewReports;
  const DashboardScreen({
    super.key,
    required this.db,
    this.onNewSale,
    this.onViewReports,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardRepository _repo = DashboardRepository(widget.db);
  late final InsightsRepository _insightsRepo = InsightsRepository(widget.db);
  late final ProductRepository _productRepo = ProductRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);
  late Future<DashboardSummary> _future;
  late Future<_DashboardInsights> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _future = _repo.getSummary();
    _insightsFuture = _loadInsights();
  }

  Future<_DashboardInsights> _loadInsights() async {
    final reorder = await _insightsRepo.getReorderSuggestions();
    final anomaly = await _insightsRepo.getTodayAnomaly();
    return (reorder: reorder, anomaly: anomaly);
  }

  /// Re-fetches the summary/insights after a quick action might have
  /// changed them (new sale, new purchase, new product).
  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _repo.getSummary();
      _insightsFuture = _loadInsights();
    });
  }

  // -------------------------------------------------------------------
  // Quick action flows — each reuses the exact same navigation/dialog
  // sequence already used on its home screen (Customers/Suppliers/Products).
  // -------------------------------------------------------------------

  Future<void> _openNewCustomerSale() async {
    final l10n = AppLocalizations.of(context)!;
    final customerId = await showDialog<int>(
      context: context,
      builder: (context) => SelectCustomerDialog(db: widget.db),
    );
    if (customerId == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.newCustomerSaleTitle),
            leading: const BackButton(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomerSaleScreen(db: widget.db, customerId: customerId),
          ),
        ),
      ),
    );
    _reload();
  }

  Future<void> _openNewPurchase() async {
    final l10n = AppLocalizations.of(context)!;
    final supplierId = await showDialog<int>(
      context: context,
      builder: (context) => SelectSupplierDialog(db: widget.db),
    );
    if (supplierId == null || !mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.newPurchaseAction),
            leading: const BackButton(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: NewPurchaseScreen(db: widget.db, supplierId: supplierId),
          ),
        ),
      ),
    );
    _reload();
  }

  Future<void> _openAddProduct() async {
    final categoriesWithCounts = await _categoryRepo.getAllWithCounts();
    if (!mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(
        repo: _productRepo,
        categories: categoriesWithCounts.map((c) => c.category).toList(),
      ),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final l10n = AppLocalizations.of(context)!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: l10n.dashboardTitle,
                subtitle: l10n.dashboardSubtitle,
              ),
              Panel(
                title: l10n.quickActionsPanel,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickActionCard(
                        icon: Icons.point_of_sale_outlined,
                        label: l10n.newSaleAction,
                        onTap: widget.onNewSale,
                      ),
                      _QuickActionCard(
                        icon: Icons.person_add_alt_outlined,
                        label: l10n.newCustomerSaleTitle,
                        onTap: _openNewCustomerSale,
                      ),
                      _QuickActionCard(
                        icon: Icons.local_shipping_outlined,
                        label: l10n.newPurchaseAction,
                        onTap: _openNewPurchase,
                      ),
                      _QuickActionCard(
                        icon: Icons.add_box_outlined,
                        label: l10n.addProduct,
                        onTap: _openAddProduct,
                      ),
                      _QuickActionCard(
                        icon: Icons.bar_chart_outlined,
                        label: l10n.viewReportsAction,
                        onTap: widget.onViewReports,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<_DashboardInsights>(
                future: _insightsFuture,
                builder: (context, snapshot) {
                  final insights = snapshot.data;
                  if (insights == null) return const SizedBox.shrink();
                  final banners = <Widget>[];
                  if (insights.reorder.isNotEmpty) {
                    banners.add(
                      _InsightBanner(
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFFF2A93B),
                        message: l10n.reorderNoticeMessage(
                          insights.reorder.length,
                        ),
                        onView: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InsightsScreen(db: widget.db),
                          ),
                        ),
                        viewLabel: l10n.viewAllAction,
                      ),
                    );
                  }
                  final anomaly = insights.anomaly;
                  if (anomaly != null) {
                    banners.add(
                      _InsightBanner(
                        icon: anomaly.isLow
                            ? Icons.trending_down
                            : Icons.trending_up,
                        color: anomaly.isLow
                            ? const Color(0xFFE4572E)
                            : const Color(0xFF16A34A),
                        message: anomaly.isLow
                            ? l10n.todayAnomalyLowMessage(
                                formatMoney(anomaly.todayRevenue),
                                formatMoney(anomaly.avgRevenue),
                              )
                            : l10n.todayAnomalyHighMessage(
                                formatMoney(anomaly.todayRevenue),
                                formatMoney(anomaly.avgRevenue),
                              ),
                        onView: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InsightsScreen(db: widget.db),
                          ),
                        ),
                        viewLabel: l10n.viewAllAction,
                      ),
                    );
                  }
                  if (banners.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...banners.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: b,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final stats = [
                    StatCard(
                      label: l10n.statProducts,
                      value: '${data.productCount}',
                      icon: Icons.inventory_2_outlined,
                      accentColor: const Color(0xFF0E7C7B),
                    ),
                    StatCard(
                      label: l10n.statCategories,
                      value: '${data.categoryCount}',
                      icon: Icons.category_outlined,
                      accentColor: const Color(0xFFF2A93B),
                    ),
                    StatCard(
                      label: l10n.statTodaySales,
                      value: formatMoney(data.todaySalesTotal),
                      hint: l10n.salesCount(data.todaySalesCount),
                      icon: Icons.point_of_sale_outlined,
                      accentColor: const Color(0xFF16A34A),
                    ),
                    StatCard(
                      label: l10n.statLowStock,
                      value: '${data.lowStockProducts.length}',
                      icon: Icons.warning_amber_outlined,
                      accentColor: const Color(0xFFE4572E),
                    ),
                  ];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 152,
                        ),
                    itemCount: stats.length,
                    itemBuilder: (context, i) => stats[i],
                  );
                },
              ),
              const SizedBox(height: 24),
              Panel(
                title: l10n.lowStockPanelTitle,
                description: l10n.lowStockPanelDesc(
                  data.lowStockProducts.length,
                ),
                child: Column(
                  children: data.lowStockProducts.isEmpty
                      ? [
                          EmptyState(
                            icon: Icons.check_circle_outline,
                            title: l10n.noLowStockProducts,
                          ),
                        ]
                      : data.lowStockProducts
                            .take(5)
                            .map(
                              (p) => ListTile(
                                title: Text(productDisplayName(p)),
                                trailing: Text(
                                  l10n.unitsLeft(
                                    formatQuantity(p.stockQuantity, p.unitType),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  final stats = [
                    StatCard(
                      label: l10n.statCustomersOwe,
                      value: formatMoney(data.customersOwed),
                      icon: Icons.people_outline,
                      accentColor: const Color(0xFFE4572E),
                    ),
                    StatCard(
                      label: l10n.statOwedToSuppliers,
                      value: formatMoney(data.owedToSuppliers),
                      icon: Icons.local_shipping_outlined,
                      accentColor: const Color(0xFF0E7C7B),
                    ),
                  ];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
              const SizedBox(height: 24),
              Panel(
                title: l10n.recentActivityPanel,
                actions: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ActivityLogScreen(db: widget.db),
                    ),
                  ),
                  child: Text(l10n.viewAllAction),
                ),
                child: data.recentActivity.isEmpty
                    ? EmptyState(
                        icon: Icons.history_toggle_off,
                        title: l10n.noRecentActivity,
                      )
                    : Column(
                        children: data.recentActivity.map((entry) {
                          final color =
                              activityActionColors[entry.action] ??
                              Theme.of(context).colorScheme.primary;
                          final icon =
                              activityCategoryIcons[entry.category] ??
                              Icons.history_edu_outlined;
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, size: 18, color: color),
                            ),
                            title: Text(
                              formatActivityLogEntry(
                                l10n,
                                category: entry.category,
                                action: entry.action,
                                amount: entry.amount,
                                entityName: entry.entityLabel,
                                refId: entry.refId,
                              ),
                            ),
                            trailing: Text(
                              formatActivityTimestamp(l10n, entry.createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A tappable shortcut card for the Dashboard's "Quick Actions" row — icon
/// in a small teal-tinted badge, label below, with a border and press
/// feedback consistent with buttons elsewhere in the app. `onTap: null`
/// renders it disabled rather than hidden, since a quick action can depend
/// on a callback the host screen didn't wire up.
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const teal = Color(0xFF0E7C7B);
    final enabled = onTap != null;
    return SizedBox(
      width: 168,
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: teal.withValues(alpha: enabled ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: enabled ? teal : teal.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback onView;
  final String viewLabel;
  const _InsightBanner({
    required this.icon,
    required this.color,
    required this.message,
    required this.onView,
    required this.viewLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          TextButton(onPressed: onView, child: Text(viewLabel)),
        ],
      ),
    );
  }
}
