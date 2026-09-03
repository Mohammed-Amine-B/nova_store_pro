import 'package:flutter/material.dart';

/// Design tokens for the new visual language introduced on the Product
/// Detail screen. Intended to be reused by later screens as the rest of the
/// app is migrated to this look, without touching the app's existing global
/// [ThemeData] (which many other still-unmigrated screens still rely on).
class DesignColors {
  DesignColors._();

  static const background = Color(0xFFF5F2EC);
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE6E0D5);
  static const textPrimary = Color(0xFF1D2422);
  static const textMuted = Color(0xFF6D7873);
  static const teal = Color(0xFF0D6B62);
  static const tealHover = Color(0xFF0A544D);
  static const tealTint = Color(0xFFE3F0ED);
  static const warningBg = Color(0xFFFDF6E8);
  static const warningBorder = Color(0xFFF2E4C4);
  static const warningText = Color(0xFF8A6321);
  static const destructiveText = Color(0xFFB8452F);
  static const destructiveBorder = Color(0xFFF0D5D0);
}

class DesignRadii {
  DesignRadii._();

  static const card = 16.0;
  static const inner = 12.0;
}

/// Font-family notes (deliberate, see product_detail_screen.dart summary):
/// - Body text on redesigned screens uses Flutter's built-in 'Roboto'
///   instead of this app's usual bundled 'Amiri', since the reference design
///   calls for a distinct clean sans-serif. 'IBM Plex Sans Arabic' from the
///   reference could NOT be bundled this pass (no way to fetch the actual
///   font binaries in this environment) — Roboto is Flutter's built-in
///   default, requires no asset bundling and no network fetch (unlike
///   `google_fonts`), so it was used as the offline-safe fallback instead.
/// - Numbers/codes/prices/dates use the generic 'monospace' family for the
///   same reason — no bundled monospace font was available to add this pass.
class DesignFonts {
  DesignFonts._();

  static const sans = 'Roboto';
  static const mono = 'monospace';
}

/// Reapplies [DesignFonts.sans] on top of an existing (already
/// scaled/weighted) TextStyle from the app's TextTheme, so redesigned
/// screens keep respecting the Small/Medium/Large font-size setting while
/// only swapping which typeface is used.
TextStyle? designSans(TextStyle? base, {Color? color, FontWeight? fontWeight}) {
  return base?.copyWith(
    fontFamily: DesignFonts.sans,
    color: color ?? base.color,
    fontWeight: fontWeight ?? base.fontWeight,
  );
}

/// Same as [designSans] but for numeric/code content — swaps in the
/// monospace family instead.
TextStyle? designMono(TextStyle? base, {Color? color, FontWeight? fontWeight}) {
  return base?.copyWith(
    fontFamily: DesignFonts.mono,
    color: color ?? base.color,
    fontWeight: fontWeight ?? base.fontWeight,
  );
}
