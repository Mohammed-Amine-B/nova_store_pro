import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Lays out a row of [KpiCard]s (or any fixed-min-width cards) responsively:
/// as many equal-width columns as fit at [minCardWidth], wrapping to fewer
/// columns (down to 1) as the available width shrinks.
class KpiRow extends StatelessWidget {
  final List<Widget> children;
  final double minCardWidth;
  final double spacing;

  const KpiRow({
    super.key,
    required this.children,
    this.minCardWidth = 190,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + spacing) / (minCardWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
        );
      },
    );
  }
}

/// One of the small stat cards in a KPI row (see design_tokens.dart for the
/// palette this belongs to). [value] should already be fully formatted
/// (money/quantity string) — it's rendered in the monospace font since it's
/// numeric content. Set [hero] for the single visually-distinct solid-teal
/// card in a row (e.g. "Stock Value").
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? note;
  final Color? noteColor;
  final bool hero;
  final IconData? icon;
  /// When set (and [hero] is false), [icon] is rendered inside a small
  /// colored rounded-square badge above the label — the pastel icon-badge
  /// treatment from stat_card.dart — instead of a plain inline icon.
  final Color? badgeColor;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.noteColor,
    this.hero = false,
    this.icon,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = hero
        ? Colors.white.withValues(alpha: 0.85)
        : DesignColors.textMuted;
    final valueColor = hero ? Colors.white : DesignColors.textPrimary;
    final noteColorResolved =
        noteColor ?? (hero ? Colors.white.withValues(alpha: 0.75) : DesignColors.textMuted);
    final showBadge = !hero && icon != null && badgeColor != null;

    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hero ? DesignColors.teal : DesignColors.card,
        borderRadius: BorderRadius.circular(DesignRadii.card),
        border: hero ? null : Border.all(color: DesignColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: badgeColor),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: designSans(theme.textTheme.labelMedium, color: labelColor, fontWeight: FontWeight.w600),
            ),
          ] else
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: labelColor),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: designSans(theme.textTheme.labelMedium, color: labelColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: designMono(
              theme.textTheme.headlineSmall,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: designSans(theme.textTheme.labelSmall, color: noteColorResolved),
            ),
          ],
        ],
      ),
    );
  }
}
