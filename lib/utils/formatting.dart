String formatQuantity(double value, String unitType) {
  final unitLabel = switch (unitType) {
    'kg' => 'kg',
    'meter' => 'm',
    _ => '',
  };
  String formatted;
  if (unitType == 'piece') {
    formatted = value.round().toString();
  } else if (value.truncateToDouble() == value) {
    formatted = value.toStringAsFixed(0);
  } else {
    formatted = value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return unitLabel.isEmpty ? formatted : '$formatted $unitLabel';
}

String formatMoney(double value) => '${value.toStringAsFixed(2)} DA';

/// Plain numeric text for editable fields — no unit suffix, no trailing ".0".
String plainNumber(double value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toString();