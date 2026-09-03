import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// A rounded white card matching the new design language (see
/// design_tokens.dart) — background, border, and corner radius only. Callers
/// own their own internal padding/layout, same as [Container].
class DesignCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  const DesignCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? DesignColors.card,
        borderRadius: BorderRadius.circular(DesignRadii.card),
        border: Border.all(color: borderColor ?? DesignColors.cardBorder),
      ),
      child: child,
    );
  }
}

/// A section title used inside [DesignCard]s across the redesign — sans
/// font, muted-but-legible weight, mapped onto the theme's `titleSmall` so
/// it still scales with the font-size setting.
class DesignSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const DesignSectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final style = designSans(
      Theme.of(context).textTheme.titleSmall,
      color: DesignColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: style),
        ?trailing,
      ],
    );
  }
}
