import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/customer_repository.dart';
import '../../l10n/generated/app_localizations.dart';

class CustomerFormDialog extends StatefulWidget {
  final CustomerRepository repo;
  final Customer? editing;

  const CustomerFormDialog({super.key, required this.repo, this.editing});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  late final _nameController = TextEditingController(
    text: widget.editing?.name ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.editing?.phone ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.editing?.note ?? '',
  );

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    int savedId;
    if (widget.editing == null) {
      savedId = await widget.repo.add(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
    } else {
      savedId = widget.editing!.id;
      await widget.repo.update(
        id: widget.editing!.id,
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
    }
    if (mounted) Navigator.pop(context, savedId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
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
              Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.editing == null ? l10n.addCustomer : l10n.editCustomer,
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
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneOptionalLabel,
                  border: const OutlineInputBorder(),
                ),
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
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
