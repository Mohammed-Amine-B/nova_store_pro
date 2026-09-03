import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/database/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/sales_day_view.dart';
import '../../widgets/quick_add_sale_bar.dart';

class TodaySalesScreen extends StatefulWidget {
  final AppDatabase db;
  final FocusNode?
  searchFocusNode; // optional external node (e.g. for a global Ctrl+N shortcut)
  const TodaySalesScreen({super.key, required this.db, this.searchFocusNode});

  @override
  State<TodaySalesScreen> createState() => _TodaySalesScreenState();
}

class _TodaySalesScreenState extends State<TodaySalesScreen> {
  final _viewKey = GlobalKey<SalesDayViewState>();
  late final FocusNode _searchFocusNode = widget.searchFocusNode ?? FocusNode();
  late final DateTime _today = DateTime.now();
  int _salesCount = 0;

  @override
  void dispose() {
    if (widget.searchFocusNode == null) _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyF &&
            HardwareKeyboard.instance.isControlPressed) {
          _searchFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: l10n.todaySalesTitle,
              subtitle: DateFormat(
                'EEEE, MMMM d',
                Localizations.localeOf(context).toString(),
              ).format(_today),
              actions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _viewKey.currentState?.printSummary(),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: Text(l10n.printSavePdfTooltip),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _searchFocusNode.requestFocus(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newSaleAction),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: QuickAddSaleBar(
                    db: widget.db,
                    date: _today,
                    focusNode: _searchFocusNode,
                    minimalHeader: true,
                    label: l10n.addProductLabel,
                    onAdded: () => _viewKey.currentState?.reload(),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.salesCount(_salesCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SalesDayView(
              key: _viewKey,
              db: widget.db,
              date: _today,
              title: '',
              panelTitle: l10n.salesTodayPanel,
              compact: true,
              fourStatCards: true,
              showTimeColumn: true,
              showTotalFooter: true,
              onSalesCountChanged: (count) =>
                  setState(() => _salesCount = count),
            ),
          ],
        ),
      ),
    );
  }
}
