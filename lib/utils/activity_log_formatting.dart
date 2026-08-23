import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'formatting.dart';

/// Icon per activity category, shared by the Activity Log screen and the
/// Dashboard's recent-activity panel.
const activityCategoryIcons = {
  'sale': Icons.point_of_sale_outlined,
  'purchase': Icons.local_shipping_outlined,
  'return': Icons.assignment_return_outlined,
  'product': Icons.inventory_2_outlined,
  'category': Icons.category_outlined,
  'customer': Icons.people_outline,
  'supplier': Icons.local_shipping_outlined,
  'payment': Icons.payments_outlined,
};

/// Icon tint per activity action, shared the same way.
const activityActionColors = {
  'created': Color(0xFF16A34A),
  'updated': Color(0xFFF2A93B),
  'deleted': Color(0xFFE4572E),
  'archived': Color(0xFFE4572E),
  'restored': Color(0xFF0E7C7B),
};

/// Translated label for an activity category key (or 'all').
String activityCategoryLabel(AppLocalizations l10n, String key) => switch (key) {
      'all' => l10n.catAll,
      'sale' => l10n.catSale,
      'purchase' => l10n.catPurchase,
      'return' => l10n.catReturn,
      'product' => l10n.catProduct,
      'category' => l10n.catCategory,
      'customer' => l10n.catCustomer,
      'supplier' => l10n.catSupplier,
      'payment' => l10n.catPayment,
      _ => key,
    };

/// Short relative/absolute timestamp for an activity entry.
String formatActivityTimestamp(AppLocalizations l10n, DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24 && dt.day == now.day) return l10n.hoursAgo(diff.inHours);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Builds the translated, human-readable sentence for one activity log entry
/// from its structured fields, using the ARB template that matches its
/// category+action pair.
String formatActivityLogEntry(
  AppLocalizations l10n, {
  required String category,
  required String action,
  double? amount,
  String? entityName,
  int? refId,
}) {
  final name = entityName ?? (refId != null ? '#$refId' : '?');
  final money = amount != null ? formatMoney(amount) : '';

  switch ((category, action)) {
    case ('sale', 'created'):
      return entityName != null
          ? l10n.activityLogSaleCreatedFor(money, entityName)
          : l10n.activityLogSaleCreated(money);
    case ('sale', 'updated'):
      return l10n.activityLogSaleUpdated(refId ?? 0);
    case ('sale', 'deleted'):
      return l10n.activityLogSaleDeleted(refId ?? 0);
    case ('purchase', 'created'):
      return l10n.activityLogPurchaseCreated(money, name);
    case ('purchase', 'updated'):
      return l10n.activityLogPurchaseUpdated(refId ?? 0);
    case ('return', 'created'):
      return l10n.activityLogReturnCreated(refId ?? 0, money);
    case ('product', 'created'):
      return l10n.activityLogProductCreated(name);
    case ('product', 'updated'):
      return l10n.activityLogProductUpdated(name);
    case ('product', 'deleted'):
      return l10n.activityLogProductDeleted(name);
    case ('product', 'archived'):
      return l10n.activityLogProductArchived(name);
    case ('product', 'restored'):
      return l10n.activityLogProductRestored(name);
    case ('category', 'created'):
      return l10n.activityLogCategoryCreated(name);
    case ('category', 'updated'):
      return l10n.activityLogCategoryUpdated(name);
    case ('category', 'deleted'):
      return l10n.activityLogCategoryDeleted(name);
    case ('customer', 'created'):
      return l10n.activityLogCustomerCreated(name);
    case ('customer', 'updated'):
      return l10n.activityLogCustomerUpdated(name);
    case ('customer', 'archived'):
      return l10n.activityLogCustomerArchived(name);
    case ('customer', 'restored'):
      return l10n.activityLogCustomerRestored(name);
    case ('supplier', 'created'):
      return l10n.activityLogSupplierCreated(name);
    case ('supplier', 'updated'):
      return l10n.activityLogSupplierUpdated(name);
    case ('supplier', 'archived'):
      return l10n.activityLogSupplierArchived(name);
    case ('supplier', 'restored'):
      return l10n.activityLogSupplierRestored(name);
    case ('payment', 'created'):
      return l10n.activityLogPaymentReceived(money, name);
    default:
      return '$category $action';
  }
}
