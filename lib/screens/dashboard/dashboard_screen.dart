import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/panel.dart';
import '../../utils/formatting.dart';

class DashboardScreen extends StatefulWidget {
  final AppDatabase db;
  const DashboardScreen({super.key, required this.db});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardRepository _repo = DashboardRepository(widget.db);
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getSummary();
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
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
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
                ],
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
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(l10n.noLowStockProducts),
                          ),
                        ]
                      : data.lowStockProducts
                            .map(
                              (p) => ListTile(
                                title: Text(p.name),
                                trailing: Text(
                                  l10n.unitsLeft(formatQuantity(p.stockQuantity, p.unitType)),
                                ),
                              ),
                            )
                            .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
