import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/note_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import 'note_form_dialog.dart';

class NotesScreen extends StatefulWidget {
  final AppDatabase db;
  const NotesScreen({super.key, required this.db});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NoteRepository _repo = NoteRepository(widget.db);
  List<Note> _notes = [];
  bool _loading = true;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final notes = await _repo.getAll(type: _typeFilter);
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _onTypeFilterChanged(String? type) async {
    setState(() => _typeFilter = type);
    await _reload();
  }

  Future<void> _openForm({Note? editing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => NoteFormDialog(repo: _repo, editing: editing),
    );
    if (saved == true) await _reload();
  }

  Future<void> _toggleDone(Note note, bool isDone) async {
    await _repo.markDone(note.id, isDone);
    await _reload();
  }

  Future<void> _delete(Note note) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteNoteTitle,
      message: l10n.deleteNoteMessage(note.title),
      confirmLabel: l10n.delete,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_outline,
    );
    if (confirmed) {
      await _repo.delete(note.id);
      await _reload();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _typeBadge(String type, AppLocalizations l10n) {
    final (label, color) = switch (type) {
      'product_to_add' => (l10n.noteTypeProductToAdd, const Color(0xFF0E7C7B)),
      'customer_request' => (
        l10n.noteTypeCustomerRequest,
        const Color(0xFFF2A93B),
      ),
      _ => (l10n.noteTypeGeneral, Colors.grey),
    };
    return _TypeBadge(label: label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final notes = _notes;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.notesTitle,
          subtitle: l10n.notesSubtitle,
          actions: FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addNote),
          ),
        ),
        Expanded(
          child: Panel(
            title: l10n.allNotesPanel,
            description: l10n.notesCount(notes.length),
            actions: SegmentedButton<String?>(
              segments: [
                ButtonSegment(value: null, label: Text(l10n.filterAll)),
                ButtonSegment(
                  value: 'product_to_add',
                  label: Text(l10n.noteTypeProductToAdd),
                ),
                ButtonSegment(
                  value: 'customer_request',
                  label: Text(l10n.noteTypeCustomerRequest),
                ),
                ButtonSegment(
                  value: 'general',
                  label: Text(l10n.noteTypeGeneral),
                ),
              ],
              selected: {_typeFilter},
              onSelectionChanged: (s) => _onTypeFilterChanged(s.first),
            ),
            child: notes.isEmpty
                ? EmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: l10n.noNotesYet,
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final note = notes[i];
                      return ListTile(
                        onTap: () => _openForm(editing: note),
                        leading: Checkbox(
                          value: note.isDone,
                          activeColor: const Color(0xFF0E7C7B),
                          onChanged: (v) => _toggleDone(note, v ?? false),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                note.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: note.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: note.isDone
                                      ? theme.colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _typeBadge(note.type, l10n),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.content != null &&
                                note.content!.trim().isNotEmpty)
                              Text(
                                note.content!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(note.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine:
                            note.content != null &&
                            note.content!.trim().isNotEmpty,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _delete(note),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
