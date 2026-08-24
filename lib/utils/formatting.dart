import 'package:intl/intl.dart';
import '../data/database/database.dart';

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

final _moneyFormat = NumberFormat('#,##0.00');

String formatMoney(double value) => '${_moneyFormat.format(value)} DA';

/// Splits a balance into display text and whether it's a credit (shop owes
/// them) rather than money owed to the shop. Negative balances are shown as
/// "Credit: {amount}" instead of a confusing minus sign.
(String text, bool isCredit) formatBalance(double balance) {
  if (balance < 0) return ('Credit: ${formatMoney(balance.abs())}', true);
  return (formatMoney(balance), false);
}

/// Plain numeric text for editable fields — no unit suffix, no trailing ".0".
String plainNumber(double value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toString();

/// Product name with its size appended in parentheses if set, e.g. "Screw (4mm)".
/// Use this instead of raw `product.name` anywhere a product is displayed in a
/// sale, purchase, or product context.
String productDisplayName(Product product) {
  if (product.variantSize == null || product.variantSize!.trim().isEmpty) {
    return product.name;
  }
  return '${product.name} (${product.variantSize})';
}