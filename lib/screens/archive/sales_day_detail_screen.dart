import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/sales_day_view.dart';
import '../../widgets/quick_add_sale_bar.dart';

class SalesDayDetailScreen extends StatefulWidget {
  final AppDatabase db;
  final DateTime date;
  const SalesDayDetailScreen({super.key, required this.db, required this.date});

  @override
  State<SalesDayDetailScreen> createState() => _SalesDayDetailScreenState();
}

class _SalesDayDetailScreenState extends State<SalesDayDetailScreen> {
  final _viewKey = GlobalKey<SalesDayViewState>();

  String _formatLongDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesForDate(_formatLongDate(widget.date))),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickAddSaleBar(
              db: widget.db,
              date: widget.date,
              onAdded: () => _viewKey.currentState?.reload(),
            ),
            SalesDayView(
              key: _viewKey,
              db: widget.db,
              date: widget.date,
              title: '',
              panelTitle: l10n.salesPanel,
            ),
          ],
        ),
      ),
    );
  }
}
