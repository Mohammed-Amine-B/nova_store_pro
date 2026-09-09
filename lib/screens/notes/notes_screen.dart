import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';
import '../archive/sales_day_detail_screen.dart';
import '../products/product_form_dialog.dart';
import 'note_form_dialog.dart';

class NotesScreen extends StatefulWidget {
  final AppDatabase db;

  /// Switches the app to the Today Sales tab — called when a note's "Go to
  /// that day's sales" action targets today's date. Null disables the
  /// action for today-dated notes (a past-dated note still navigates to its
  /// Archive day-detail page regardless).
  final VoidCallback? onGoToTodaySales;
  const NotesScreen({super.key, required this.db, this.onGoToTodaySales});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NoteRepository _repo = NoteRepository(widget.db);
  late final ProductRepository _productRepo = ProductRepository(widget.db);
  late final CategoryRepository _categoryRepo = CategoryRepository(widget.db);
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

  Future<void> _addNewProductForNote(Note note) async {
    final categoriesWithCounts = await _categoryRepo.getAllWithCounts();
    if (!mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(
        repo: _productRepo,
        categories: categoriesWithCounts.map((c) => c.category).toList(),
        initialName: note.title,
      ),
    );
    if (saved == true) {
      await _repo.markDone(note.id, true);
      await _reload();
    }
  }

  Future<void> _linkExistingProductForNote(Note note) async {
    final selected = await showDialog<Product>(
      context: context,
      builder: (context) => _LinkProductDialog(repo: _productRepo),
    );
    if (selected == null) return;
    await _repo.markDone(note.id, true);
    await _reload();
  }

  Future<void> _goToDayForNote(Note note) async {
    final noteDate = note.createdAt;
    final today = DateTime.now();
    final isToday =
        noteDate.year == today.year &&
        noteDate.month == today.month &&
        noteDate.day == today.day;
    if (isToday) {
      widget.onGoToTodaySales?.call();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SalesDayDetailScreen(db: widget.db, date: noteDate),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Purely informational — never a real counted amount, so this is plain
  /// text, not [formatMoney]/`MoneyText`-styled like actual revenue figures.
  String? _notedAmountText(Note note, AppLocalizations l10n) {
    final price = note.price;
    final quantity = note.quantity;
    if (price != null && quantity != null) {
      return l10n.notedQuantityAndPrice(
        plainNumber(quantity),
        plainNumber(price),
      );
    }
    if (quantity != null) return l10n.notedQuantityOnly(plainNumber(quantity));
    if (price != null) return l10n.notedPriceOnly(plainNumber(price));
    return null;
  }

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
                      final notedText = _notedAmountText(note, l10n);
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
                            if (notedText != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                notedText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                            ],
                            if (note.type == 'product_to_add' &&
                                !note.isDone) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _addNewProductForNote(note),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0E7C7B),
                                      side: const BorderSide(
                                        color: Color(0xFF0E7C7B),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: Text(
                                      l10n.addNewProductAction,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _linkExistingProductForNote(note),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0E7C7B),
                                      side: const BorderSide(
                                        color: Color(0xFF0E7C7B),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                    ),
                                    icon: const Icon(Icons.link, size: 14),
                                    label: Text(
                                      l10n.linkExistingProductAction,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        isThreeLine:
                            note.content != null &&
                            note.content!.trim().isNotEmpty,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.point_of_sale_outlined,
                                size: 20,
                                color: Color(0xFF0E7C7B),
                              ),
                              tooltip: l10n.goToDaySalesTooltip,
                              onPressed: () => _goToDayForNote(note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              tooltip: l10n.delete,
                              onPressed: () => _delete(note),
                            ),
                          ],
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

/// A simple search-as-you-type product picker, used to resolve a
/// "product_to_add" note by linking it to a product that already exists —
/// mirrors the search pattern used in QuickAddSaleBar/CustomerSaleScreen.
class _LinkProductDialog extends StatefulWidget {
  final ProductRepository repo;
  const _LinkProductDialog({required this.repo});

  @override
  State<_LinkProductDialog> createState() => _LinkProductDialogState();
}

class _LinkProductDialogState extends State<_LinkProductDialog> {
  final _searchController = TextEditingController();
  List<Product> _results = [];

  @override
  void initState() {
    super.initState();
    _onSearchChanged('');
  }

  Future<void> _onSearchChanged(String query) async {
    final results = await widget.repo.search(query);
    if (!mounted) return;
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.linkExistingProductAction),
      content: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchProductsHint,
                prefixIcon: const Icon(Icons.search, size: 18),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text(l10n.noProductsFound))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final p = _results[i];
                        return ListTile(
                          dense: true,
                          title: Text(productDisplayName(p)),
                          subtitle: Text(p.barcode ?? p.code),
                          onTap: () => Navigator.pop(context, p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
