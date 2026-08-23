import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatting.dart';
import 'supplier_form_dialog.dart';
import 'supplier_detail_screen.dart';
import 'new_purchase_screen.dart';
import 'select_supplier_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  final AppDatabase db;
  const SuppliersScreen({super.key, required this.db});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SupplierRepository _repo = SupplierRepository(widget.db);
  bool _showingArchived = false;

  List<Supplier> _all = [];
  Map<int, double> _totals = {};
  Map<int, double> _owed = {};
  bool _loading = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = _showingArchived ? await _repo.getArchived() : await _repo.getAllActive();
    final totals = <int, double>{};
    final owed = <int, double>{};
    for (final s in all) {
      totals[s.id] = await _repo.totalPurchasedFrom(s.id);
      owed[s.id] = await _repo.getRemainingOwed(s.id);
    }
    if (!mounted) return;
    setState(() {
      _all = all;
      _totals = totals;
      _owed = owed;
      _loading = false;
    });
  }

  void _toggleArchivedView() {
    setState(() {
      _showingArchived = !_showingArchived;
      _loading = true;
    });
    _load();
  }

  Future<void> _restoreSupplier(Supplier supplier) async {
    await _repo.unarchive(supplier.id);
    _load();
  }

  List<Supplier> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((s) {
      return s.name.toLowerCase().contains(q) ||
          (s.location ?? '').toLowerCase().contains(q) ||
          (s.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openAddDialog({Supplier? editing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => SupplierFormDialog(repo: _repo, editing: editing),
    );
    if (saved == true) _load();
  }

  Future<void> _openDetail(Supplier supplier) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SupplierDetailScreen(db: widget.db, supplierId: supplier.id),
      ),
    );
    _load();
  }

  Future<void> _openNewPurchase() async {
    final l10n = AppLocalizations.of(context)!;
    final supplierId = await showDialog<int>(
      context: context,
      builder: (context) => SelectSupplierDialog(db: widget.db),
    );
    if (supplierId == null || !mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.newPurchaseAction), leading: const BackButton()),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: NewPurchaseScreen(db: widget.db, supplierId: supplierId),
          ),
        ),
      ),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final rows = _filtered;
    final totalPurchased = _totals.values.fold<double>(0, (sum, v) => sum + v);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.suppliersTitle,
            subtitle: l10n.suppliersSubtitle,
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _toggleArchivedView,
                  icon: Icon(_showingArchived ? Icons.local_shipping_outlined : Icons.archive_outlined, size: 18),
                  label: Text(_showingArchived ? l10n.viewActive : l10n.viewArchived),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _openNewPurchase,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(l10n.newPurchaseAction),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openAddDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addSupplier),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.6,
            children: [
              StatCard(
                label: l10n.statTotalSuppliers,
                value: '${_all.length}',
                icon: Icons.local_shipping_outlined,
                accentColor: const Color(0xFF0E7C7B),
              ),
              StatCard(
                label: l10n.statTotalPurchased,
                value: formatMoney(totalPurchased),
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFF16A34A),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Panel(
            title: l10n.allSuppliersPanel,
            description: l10n.shownOfTotal(rows.length, _all.length),
            actions: SizedBox(
              width: 220,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  hintText: l10n.searchSuppliersHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            child: rows.isEmpty
                ? EmptyState(icon: Icons.local_shipping_outlined, title: l10n.noSuppliersMatch)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            showCheckboxColumn: false,
                            headingRowColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                            ),
                            dataRowColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Theme.of(context).colorScheme.primary.withValues(alpha: 0.04);
                              }
                              return null;
                            }),
                            columnSpacing: 28,
                            horizontalMargin: 20,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 64,
                            columns: [
                              DataColumn(label: Text(l10n.colName)),
                              DataColumn(label: Text(l10n.colLocation)),
                              DataColumn(label: Text(l10n.colPhone)),
                              DataColumn(label: Text(l10n.statTotalPurchased), numeric: true),
                              DataColumn(label: Text(l10n.colOwed), numeric: true),
                              DataColumn(label: Text(l10n.colStatus)),
                              if (_showingArchived) DataColumn(label: Text(l10n.restoreAction)),
                            ],
                            rows: rows.map((s) {
                              return DataRow(
                                onSelectChanged: (_) => _openDetail(s),
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: const Color(0xFF0E7C7B).withValues(alpha: 0.15),
                                          child: Text(
                                            s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                              color: Color(0xFF0E7C7B),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          s.name,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(s.location ?? '—')),
                                  DataCell(Text(s.phone ?? '—')),
                                  DataCell(
                                    Text(
                                      formatMoney(_totals[s.id] ?? 0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0E7C7B),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      formatBalance(_owed[s.id] ?? 0).$1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: (_owed[s.id] ?? 0) > 0
                                            ? const Color(0xFFE4572E)
                                            : const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _showingArchived
                                        ? StatusBadge(label: l10n.statusArchived, tone: BadgeTone.neutral)
                                        : StatusBadge(label: l10n.statusActive, tone: BadgeTone.success),
                                  ),
                                  if (_showingArchived)
                                    DataCell(
                                      TextButton.icon(
                                        onPressed: () => _restoreSupplier(s),
                                        icon: const Icon(Icons.restore, size: 16),
                                        label: Text(l10n.restoreAction),
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
