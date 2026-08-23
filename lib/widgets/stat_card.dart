import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final Color? accentColor;
  final bool compact;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    required this.icon,
    this.accentColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 8 : 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(compact ? 8 : 10),
              ),
              child: Icon(icon, color: accent, size: compact ? 16 : 20),
            ),
            SizedBox(width: compact ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: (compact ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
                  SizedBox(height: compact ? 2 : 8),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: (compact ? theme.textTheme.titleLarge : theme.textTheme.headlineMedium)?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
                  if (hint != null) ...[
                    SizedBox(height: compact ? 1 : 4),
                    Text(hint!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: compact ? 11 : null,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}