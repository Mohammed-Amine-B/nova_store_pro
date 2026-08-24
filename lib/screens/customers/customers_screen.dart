import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../utils/formatting.dart';
import '../../utils/text_scale.dart';
import 'customer_form_dialog.dart';
import 'customer_detail_screen.dart';
import 'select_customer_dialog.dart';
import 'customer_sale_screen.dart';

class CustomersScreen extends StatefulWidget {
  final AppDatabase db;
  const CustomersScreen({super.key, required this.db});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late final CustomerRepository _repo = CustomerRepository(widget.db);
  bool _showingArchived = false;

  List<CustomerWithBalance> _all = [];
  bool _loading = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<CustomerWithBalance> all;
    if (_showingArchived) {
      final archived = await _repo.getArchived();
      all = [];
      for (final c in archived) {
        final balance = await _repo.getRemainingBalance(c.id);
        all.add(CustomerWithBalance(c, balance));
      }
    } else {
      all = await _repo.getAllWithBalances();
    }
    if (!mounted) return;
    setState(() {
      _all = all;
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

  Future<void> _restoreCustomer(Customer customer) async {
    await _repo.unarchive(customer.id);
    _load();
  }

  List<CustomerWithBalance> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((c) {
      return c.customer.name.toLowerCase().contains(q) ||
          (c.customer.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openAddDialog({Customer? editing}) async {
    final saved = await showDialog<int>(
      context: context,
      builder: (context) => CustomerFormDialog(repo: _repo, editing: editing),
    );
    if (saved != null) _load();
  }

  Future<void> _openDetail(Customer customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(db: widget.db, customerId: customer.id),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final rows = _filtered;
    final totalOwed = _all.fold<double>(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.customersTitle,
            subtitle: l10n.customersSubtitle,
                        actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _toggleArchivedView,
                  icon: Icon(_showingArchived ? Icons.people_outline : Icons.archive_outlined, size: 18),
                  label: Text(_showingArchived ? l10n.viewActive : l10n.viewArchived),
                ),
                const SizedBox(width: 12),
                                OutlinedButton.icon(
                  onPressed: () async {
                    final customerId = await showDialog<int>(
                      context: context,
                      builder: (context) => SelectCustomerDialog(db: widget.db),
                    );
                    if (customerId == null || !context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text(l10n.newCustomerSaleTitle), leading: const BackButton()),
                          body: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CustomerSaleScreen(db: widget.db, customerId: customerId),
                          ),
                        ),
                      ),
                    );
                    _load();
                  },
                  icon: const Icon(Icons.point_of_sale, size: 18),
                  label: Text(l10n.newSaleAction),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openAddDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addCustomer),
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
                label: l10n.statTotalCustomers,
                value: '${_all.length}',
                icon: Icons.people_outline,
                accentColor: const Color(0xFF0E7C7B),
              ),
              StatCard(
                label: l10n.statTotalOwed,
                value: formatMoney(totalOwed),
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFFE4572E),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Panel(
            title: l10n.allCustomersPanel,
            description: l10n.shownOfTotal(rows.length, _all.length),
            actions: SizedBox(
              width: 220,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  hintText: l10n.searchCustomersHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            child: rows.isEmpty
                ? EmptyState(icon: Icons.people_outline, title: l10n.noCustomersMatch)
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
                            dataRowMinHeight: 56 * dataRowScale(context),
                            dataRowMaxHeight: 64 * dataRowScale(context),
                            columns: [
                              DataColumn(label: Text(l10n.colName)),
                              DataColumn(label: Text(l10n.colPhone)),
                              DataColumn(label: Text(l10n.colBalance), numeric: true),
                              DataColumn(label: Text(l10n.colActions)),
                              if (_showingArchived) DataColumn(label: Text(l10n.restoreAction)),
                            ],
                            rows: rows.map((cwb) {
                              final c = cwb.customer;
                              final balanceDisplay = formatBalance(cwb.balance);
                              final balanceColor = cwb.balance > 0
                                  ? const Color(0xFFE4572E)
                                  : const Color(0xFF16A34A);
                              return DataRow(
                                onSelectChanged: (_) => _openDetail(c),
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: const Color(0xFF0E7C7B).withValues(alpha: 0.15),
                                          child: Text(
                                            c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                              color: Color(0xFF0E7C7B),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          c.name,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(c.phone ?? '—')),
                                  DataCell(
                                    Text(
                                      balanceDisplay.$1,
                                      style: TextStyle(fontWeight: FontWeight.w700, color: balanceColor),
                                    ),
                                  ),
                                  DataCell(
                                    TextButton.icon(
                                      onPressed: () => _openDetail(c),
                                      icon: const Icon(Icons.visibility_outlined, size: 16),
                                      label: Text(l10n.viewAction),
                                    ),
                                  ),
                                  if (_showingArchived)
                                    DataCell(
                                      TextButton.icon(
                                        onPressed: () => _restoreCustomer(c),
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
