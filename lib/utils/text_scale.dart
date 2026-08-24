import 'package:flutter/material.dart';

/// Baseline body text size the app's DataTable row heights were tuned
/// against (matches [AppTheme]'s bodyMedium at the 'medium' font-size
/// preference).
const double _baseBodyFontSize = 14;

/// Row-height scale factor derived from the current effective body text
/// size, so DataTable rows stay proportioned to the user's font-size
/// preference (Settings > Font Size) without threading the setting itself
/// through every table screen.
double dataRowScale(BuildContext context) {
  final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? _baseBodyFontSize;
  return fontSize / _baseBodyFontSize;
}
