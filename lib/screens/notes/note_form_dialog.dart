import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/note_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/enter_to_submit.dart';

class NoteFormDialog extends StatefulWidget {
  final NoteRepository repo;
  final Note? editing;

  const NoteFormDialog({super.key, required this.repo, this.editing});

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  late final _titleController = TextEditingController(
    text: widget.editing?.title ?? '',
  );
  late final _contentController = TextEditingController(
    text: widget.editing?.content ?? '',
  );
  late String _type = widget.editing?.type ?? 'general';

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    if (widget.editing == null) {
      await widget.repo.add(
        title: _titleController.text,
        content: _contentController.text.isEmpty
            ? null
            : _contentController.text,
        type: _type,
      );
    } else {
      await widget.repo.update(
        id: widget.editing!.id,
        title: _titleController.text,
        content: _contentController.text.isEmpty
            ? null
            : _contentController.text,
        type: _type,
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
                Icons.sticky_note_2_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.editing == null ? l10n.addNote : l10n.editNote,
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
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.noteTitleLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: l10n.noteContentOptionalLabel,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.noteTypeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'product_to_add',
                      child: Text(l10n.noteTypeProductToAdd),
                    ),
                    DropdownMenuItem(
                      value: 'customer_request',
                      child: Text(l10n.noteTypeCustomerRequest),
                    ),
                    DropdownMenuItem(
                      value: 'general',
                      child: Text(l10n.noteTypeGeneral),
                    ),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'general'),
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
      ),
    );
  }
}
