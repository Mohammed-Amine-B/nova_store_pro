import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/enter_to_submit.dart';

class SupplierFormDialog extends StatefulWidget {
  final SupplierRepository repo;
  final Supplier? editing;

  const SupplierFormDialog({super.key, required this.repo, this.editing});

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  late final _nameController = TextEditingController(
    text: widget.editing?.name ?? '',
  );
  late final _locationController = TextEditingController(
    text: widget.editing?.location ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.editing?.phone ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.editing?.note ?? '',
  );

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    if (widget.editing == null) {
      await widget.repo.add(
        name: _nameController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
    } else {
      await widget.repo.update(
        id: widget.editing!.id,
        name: _nameController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EnterToSubmit(
      onSubmit: _save,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.editing == null ? l10n.addSupplier : l10n.editSupplier,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.colName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: l10n.locationOptionalLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phoneOptionalLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l10n.noteOptionalLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
