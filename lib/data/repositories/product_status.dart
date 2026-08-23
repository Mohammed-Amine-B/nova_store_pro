import '../database/database.dart';
import '../../l10n/generated/app_localizations.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

ProductStatus statusOf(Product p) {
  if (p.stockQuantity <= 0) return ProductStatus.outOfStock;
  if (p.stockQuantity <= p.minStock) return ProductStatus.lowStock;
  return ProductStatus.inStock;
}

String statusLabel(ProductStatus s, AppLocalizations l10n) => switch (s) {
      ProductStatus.inStock => l10n.statusInStock,
      ProductStatus.lowStock => l10n.statusLowStock,
      ProductStatus.outOfStock => l10n.statusOutOfStock,
    };