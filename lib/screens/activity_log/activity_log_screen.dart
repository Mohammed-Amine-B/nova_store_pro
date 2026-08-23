import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/activity_log_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/activity_log_formatting.dart';
import '../../widgets/date_range_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

enum _LogRange { today, week, month, custom }

const _categories = [
  'all',
  'sale',
  'purchase',
  'return',
  'product',
  'category',
  'customer',
  'supplier',
  'payment',
];

class ActivityLogScreen extends StatefulWidget {
  final AppDatabase db;
  const ActivityLogScreen({super.key, required this.db});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late final ActivityLogRepository _repo = ActivityLogRepository(widget.db);
  _LogRange _range = _LogRange.week;
  DateTimeRange? _customRange;
  String _category = 'all';

  List<ActivityLogData> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  (DateTime, DateTime)? _resolveRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case _LogRange.today:
        return (today, today.add(const Duration(days: 1)));
      case _LogRange.week:
        return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
      case _LogRange.month:
        return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1));
      case _LogRange.custom:
        if (_customRange == null) return null;
        return (_customRange!.start, _customRange!.end.add(const Duration(days: 1)));
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final range = _resolveRange();
    final entries = await _repo.getEntries(
      category: _category == 'all' ? null : _category,
      start: range?.$1,
      end: range?.$2,
    );
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _pickCustomRange() async {
    final picked = await showCustomDateRangeDialog(
      context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _range = _LogRange.custom;
        _customRange = picked;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.activityLogTitle,
            subtitle: l10n.activityLogSubtitle,
          ),
          SegmentedButton<_LogRange>(
            segments: [
              ButtonSegment(value: _LogRange.today, label: Text(l10n.rangeToday)),
              ButtonSegment(value: _LogRange.week, label: Text(l10n.rangeWeek)),
              ButtonSegment(value: _LogRange.month, label: Text(l10n.rangeMonth)),
              ButtonSegment(value: _LogRange.custom, label: Text(l10n.rangeCustom)),
            ],
            selected: {_range},
            onSelectionChanged: (s) {
              if (s.first == _LogRange.custom) {
                _pickCustomRange();
              } else {
                setState(() => _range = s.first);
                _load();
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(activityCategoryLabel(l10n, c))))
                  .toList(),
              onChanged: (v) {
                setState(() => _category = v ?? 'all');
                _load();
              },
            ),
          ),
          const SizedBox(height: 24),
          Panel(
            title: l10n.entriesPanel,
            description: l10n.recordsCountDesc(_entries.length),
            child: _entries.isEmpty
                ? EmptyState(icon: Icons.history_toggle_off, title: l10n.noActivityInRange)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      final color = activityActionColors[entry.action] ?? theme.colorScheme.primary;
                      final icon = activityCategoryIcons[entry.category] ?? Icons.history_edu_outlined;
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        title: Text(formatActivityLogEntry(
                          l10n,
                          category: entry.category,
                          action: entry.action,
                          amount: entry.amount,
                          entityName: entry.entityLabel,
                          refId: entry.refId,
                        )),
                        subtitle: Text(activityCategoryLabel(l10n, entry.category)),
                        trailing: Text(
                          formatActivityTimestamp(l10n, entry.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
