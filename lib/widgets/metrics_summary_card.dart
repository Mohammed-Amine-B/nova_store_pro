import 'package:flutter/material.dart';
import 'money_text.dart';

class MetricItem {
  final String label;
  final String value;
  final String? hint;
  final Color valueColor;
  const MetricItem({required this.label, required this.value, this.hint, required this.valueColor});
}

class MetricsSummaryCard extends StatelessWidget {
  final List<MetricItem> items;
  const MetricsSummaryCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 40, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i].label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    letterSpacing: 0.6,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: MoneyText(
                          items[i].value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: items[i].valueColor,
                          ),
                        ),
                      ),
                      if (items[i].hint != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            items[i].hint!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}