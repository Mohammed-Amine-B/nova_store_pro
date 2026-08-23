import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/product_batches_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/sale_item_batches_table.dart';
import 'tables/settings_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/purchases_table.dart';
import 'tables/purchase_items_table.dart';
import 'tables/customers_table.dart';
import 'tables/debt_payments_table.dart';
import 'tables/returns_table.dart';
import 'tables/return_items_table.dart';
import 'tables/supplier_payments_table.dart';
import 'tables/activity_log_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Products,
    ProductBatches,
    StockMovements,
    Sales,
    SaleItems,
    SaleItemBatches,
    Settings,
    Suppliers,
    Purchases,
    PurchaseItems,
    Customers,
    DebtPayments,
    Returns,
    ReturnItems,
    SupplierPayments,
    ActivityLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bumped for ActivityLog's structured columns (amount/entityName/refId) replacing description.
  // Pre-release: no migration needed, dev DBs are just recreated.
  @override
  int get schemaVersion => 9;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'nova_store_db',
    native: DriftNativeOptions(
      databaseDirectory: () async {
        final dir = await getApplicationDocumentsDirectory();
        return Directory(p.join(dir.path, 'Nova Pro Data'));
      },
    ),
  );
}