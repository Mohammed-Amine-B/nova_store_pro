import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/category_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

class CategoriesScreen extends StatefulWidget {
  final AppDatabase db;
  const CategoriesScreen({super.key, required this.db});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryRepository _repo = CategoryRepository(widget.db);
  late Future<List<CategoryWithCount>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getAllWithCounts(); // no setState needed on first load
  }

  void _reload() {
    setState(() {
      _future = _repo.getAllWithCounts();
    });
  }
Future<void> _showAddDialog({Category? editing}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(text: editing?.name ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
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
              Icons.category_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            editing == null ? l10n.addCategory : l10n.editCategory,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  if (result == null || result.trim().isEmpty) return;
  try {
    if (editing == null) {
      await _repo.add(result);
    } else {
      await _repo.update(editing.id, result);
    }
    _reload();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

  Future<void> _confirmDelete(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteCategoryTitle,
      message: l10n.deleteCategoryMessage(category.name),
      confirmLabel: l10n.delete,
      tone: ConfirmTone.destructive,
      icon: Icons.delete_outline,
    );
    if (confirmed) {
      try {
        await _repo.delete(category.id);
        _reload();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryWithCount>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: l10n.categoriesTitle,
              subtitle: l10n.categoriesCount(items.length),
              actions: FilledButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.add),
                label: Text(l10n.addCategory),
              ),
            ),
            Expanded(
              child: Panel(
                title: l10n.allCategoriesPanel,
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(l10n.noCategoriesYet),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return ListTile(
                            title: Text(item.category.name),
                            subtitle: Text(
                              l10n.categoryProductsCount(item.productCount),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _showAddDialog(editing: item.category),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(item.category),
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
      },
    );
  }
}
