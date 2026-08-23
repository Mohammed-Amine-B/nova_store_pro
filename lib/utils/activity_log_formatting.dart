import '../l10n/generated/app_localizations.dart';
import 'formatting.dart';

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
