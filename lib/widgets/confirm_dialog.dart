import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'enter_to_submit.dart';

enum ConfirmTone { destructive, warning, neutral }

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final ConfirmTone tone;
  final IconData icon;

  /// Optional extra content shown below [message] — e.g. a colored preview
  /// of the balance/amount that will result from confirming.
  final Widget? extra;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.tone = ConfirmTone.neutral,
    this.icon = Icons.help_outline,
    this.extra,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    ConfirmTone tone = ConfirmTone.neutral,
    IconData icon = Icons.help_outline,
    Widget? extra,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        tone: tone,
        icon: icon,
        extra: extra,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = switch (tone) {
      ConfirmTone.destructive => theme.colorScheme.error,
      ConfirmTone.warning => const Color(0xFFF2994A),
      ConfirmTone.neutral => theme.colorScheme.primary,
    };
    return EnterToSubmit(
      onSubmit: () => Navigator.pop(context, true),
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (extra != null) ...[const SizedBox(height: 10), extra!],
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
