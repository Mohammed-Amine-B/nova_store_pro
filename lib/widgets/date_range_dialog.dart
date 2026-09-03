import 'package:flutter/material.dart';
import 'enter_to_submit.dart';

/// Shows a compact dialog (not the built-in full-page calendar) for picking
/// a start/end date range, using tap-to-open single-date fields.
Future<DateTimeRange?> showCustomDateRangeDialog(
  BuildContext context, {
  DateTimeRange? initialRange,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (context) => _DateRangeDialog(
      initialRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _DateRangeDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;
  const _DateRangeDialog({
    this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start;
    _end = widget.initialRange?.end;
  }

  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? widget.firstDate,
      firstDate: widget.firstDate,
      lastDate: _end ?? widget.lastDate,
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? widget.lastDate,
      firstDate: _start ?? widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final canApply = _start != null && _end != null;
    return EnterToSubmit(
      onSubmit: canApply
          ? () => Navigator.pop(
              context,
              DateTimeRange(start: _start!, end: _end!),
            )
          : null,
      child: AlertDialog(
        title: const Text('Select Date Range'),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _pickStart,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_start != null ? _format(_start!) : '—'),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickEnd,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_end != null ? _format(_end!) : '—'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: canApply
                ? () => Navigator.pop(
                    context,
                    DateTimeRange(start: _start!, end: _end!),
                  )
                : null,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
