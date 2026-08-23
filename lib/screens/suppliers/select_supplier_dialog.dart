import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'supplier_form_dialog.dart';

class SelectSupplierDialog extends StatefulWidget {
  final AppDatabase db;
  const SelectSupplierDialog({super.key, required this.db});

  @override
  State<SelectSupplierDialog> createState() => _SelectSupplierDialogState();
}

class _SelectSupplierDialogState extends State<SelectSupplierDialog> {
  late final SupplierRepository _repo = SupplierRepository(widget.db);
  List<Supplier> _suppliers = [];
  List<Supplier> _filtered = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final suppliers = await _repo.getAllActive();
    if (!mounted) return;
    setState(() {
      _suppliers = suppliers;
      _filtered = suppliers;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _suppliers : _suppliers.where((s) => s.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _addNewSupplier() async {
    final newId = await showDialog<int>(
      context: context,
      builder: (context) => SupplierFormDialog(repo: _repo),
    );
    if (newId != null && mounted) Navigator.pop(context, newId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.selectSupplierTitle),
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
                      hintText: l10n.searchSuppliersEllipsis,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(child: Text(l10n.noSuppliersFound))
                        : ListView(
                            children: _filtered.map((s) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                    child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?'),
                                  ),
                                  title: Text(s.name),
                                  subtitle: s.phone != null ? Text(s.phone!) : null,
                                  onTap: () => Navigator.pop(context, s.id),
                                )).toList(),
                          ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton.icon(
          onPressed: _addNewSupplier,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.newSupplierAction),
        ),
      ],
    );
  }
}
