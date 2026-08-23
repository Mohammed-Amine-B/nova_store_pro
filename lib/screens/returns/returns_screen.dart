import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/return_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/page_header.dart';
import '../../widgets/panel.dart';

class ReturnsScreen extends StatefulWidget {
  final AppDatabase db;
  const ReturnsScreen({super.key, required this.db});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  late final ReturnRepository _repo = ReturnRepository(widget.db);
  late Future<List<Return>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getAllReturns();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: l10n.returnsTitle, subtitle: l10n.returnsSubtitle),
          Panel(
            title: l10n.allReturnsPanel,
            child: FutureBuilder<List<Return>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
                final returns = snapshot.data!;
                if (returns.isEmpty) {
                  return Padding(padding: const EdgeInsets.all(32), child: Text(l10n.noReturnsYet));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(l10n.colDate)),
                            DataColumn(label: Text(l10n.colSaleId)),
                            DataColumn(label: Text(l10n.colReason)),
                            DataColumn(label: Text(l10n.colRefunded), numeric: true),
                          ],
                          rows: returns.map((ret) {
                            return DataRow(cells: [
                              DataCell(Text('${ret.createdAt}'.split(' ').first)),
                              DataCell(Text('#${ret.saleId}')),
                              DataCell(Text(ret.reason)),
                              DataCell(Text('${ret.totalRefunded.toStringAsFixed(2)} DA')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}