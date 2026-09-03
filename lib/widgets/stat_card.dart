import 'package:flutter/material.dart';
import 'money_text.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    // Soft pastel tint of the accent color for the card background — blended
    // toward white in light mode, toward black in dark mode (so it stays a
    // muted tint rather than washing out or over-brightening).
    final tint = isDark
        ? Color.lerp(accent, Colors.black, 0.75)!
        : Color.lerp(accent, Colors.white, 0.86)!;
    // A readable, still color-coded label — darkened in light mode,
    // lightened in dark mode so it stays legible on the tint above.
    final labelColor = HSLColor.fromColor(
      accent,
    ).withLightness(isDark ? 0.78 : 0.25).toColor();
    final badgeColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;
    final badgeSize = compact ? 32.0 : 36.0;

    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
      ),
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: compact ? 16 : 20),
              ),
              SizedBox(width: compact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? theme.textTheme.labelSmall
                                  : theme.textTheme.bodySmall)
                              ?.copyWith(
                                color: labelColor,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    SizedBox(height: compact ? 2 : 8),
                    MoneyText(
                      value,
                      style:
                          (compact
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.headlineMedium)
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                    ),
                    if (hint != null) ...[
                      SizedBox(height: compact ? 1 : 4),
                      Text(
                        hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: compact ? 11 : null,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
