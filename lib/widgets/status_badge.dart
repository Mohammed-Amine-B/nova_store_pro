import 'package:flutter/material.dart';

enum BadgeTone { success, warning, destructive, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;

  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = switch (tone) {
      BadgeTone.success => (const Color(0xFF0FA05C).withValues(alpha: 0.12), const Color(0xFF0FA05C)),
      BadgeTone.warning => (const Color(0xFFDF911A).withValues(alpha: 0.12), const Color(0xFFDF911A)),
      BadgeTone.destructive => (theme.colorScheme.error.withValues(alpha: 0.12), theme.colorScheme.error),
      BadgeTone.neutral => (theme.colorScheme.onSurface.withValues(alpha: 0.08), theme.colorScheme.onSurface.withValues(alpha: 0.7)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: theme.textTheme.labelSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}