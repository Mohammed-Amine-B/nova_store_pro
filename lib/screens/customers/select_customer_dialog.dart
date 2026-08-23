import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'customer_form_dialog.dart';

class SelectCustomerDialog extends StatefulWidget {
  final AppDatabase db;
  const SelectCustomerDialog({super.key, required this.db});

  @override
  State<SelectCustomerDialog> createState() => _SelectCustomerDialogState();
}

class _SelectCustomerDialogState extends State<SelectCustomerDialog> {
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
      _filtered = q.isEmpty ? _customers : _customers.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _addNewCustomer() async {
    final newId = await showDialog<int>(
      context: context,
      builder: (context) => CustomerFormDialog(repo: _repo),
    );
    if (newId != null && mounted) Navigator.pop(context, newId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.selectCustomerTitle),
      content: SizedBox(
        width: 380,
        height: 420,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchCustomersEllipsis,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(child: Text(l10n.noCustomersFound))
                        : ListView(
                            children: _filtered.map((c) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                    child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?'),
                                  ),
                                  title: Text(c.name),
                                  subtitle: c.phone != null ? Text(c.phone!) : null,
                                  onTap: () => Navigator.pop(context, c.id),
                                )).toList(),
                          ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton.icon(
          onPressed: _addNewCustomer,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.newCustomerAction),
        ),
      ],
    );
  }
}