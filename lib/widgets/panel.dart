import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? actions;
  final Widget child;

  const Panel({
    super.key,
    required this.title,
    this.description,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(description!, style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )),
                      ],
                    ],
                  ),
                ),
                if (actions != null) actions!,
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          child,
        ],
      ),
    );
  }
}