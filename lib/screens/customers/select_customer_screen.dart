import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import 'customer_form_dialog.dart';
import 'customer_sale_screen.dart';

class SelectCustomerScreen extends StatefulWidget {
  final AppDatabase db;
  const SelectCustomerScreen({super.key, required this.db});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  late final CustomerRepository _repo = CustomerRepository(widget.db);
  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customers = await _repo.getAllActive();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _filtered = customers;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _customers
          : _customers.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _addNewCustomer() async {
    final newId = await showDialog<int>(
      context: context,
      builder: (context) => CustomerFormDialog(repo: _repo),
    );
    if (newId != null && mounted) _selectCustomer(newId);
  }

  void _selectCustomer(int customerId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerSaleScreen(db: widget.db, customerId: customerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: l10n.newCustomerSaleTitle, subtitle: l10n.chooseWhoSaleFor),
          Panel(
            title: l10n.customersTitle,
            actions: OutlinedButton.icon(
              onPressed: _addNewCustomer,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newCustomerAction),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchCustomersEllipsis,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  if (_filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.noCustomersFound),
                    )
                  else
                    ..._filtered.map((c) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                            child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(c.name),
                          subtitle: c.phone != null ? Text(c.phone!) : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectCustomer(c.id),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}