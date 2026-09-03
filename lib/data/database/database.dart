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
import 'tables/customer_debt_adjustments_table.dart';
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
    CustomerDebtAdjustments,
    Returns,
    ReturnItems,
    SupplierPayments,
    ActivityLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bumped for removal of Products.variantGroup (superseded by matching
  // variants on product name — see ProductRepository.getVariants). One-time
  // exception to the migration-required rule below: no real onUpgrade step
  // was written for this column removal since the app has no production data
  // yet; the local dev SQLite database needs to be deleted once for this
  // change. All schema changes after this one still require a real migration.
  @override
  int get schemaVersion => 16;

  // Baseline: schema version 9 as of 2026-08-23. All future schema changes must
  // add a migration step in onUpgrade below — never tell a user to delete their
  // database again.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration steps go here, one `if` block per version jump, added
          // incrementally as the schema changes in the future.
          if (from < 10) {
            await m.addColumn(settings, settings.securityQuestion);
            await m.addColumn(settings, settings.securityAnswerHash);
            await m.addColumn(settings, settings.recoveryCodeHash);
          }
          if (from < 11) {
            await m.addColumn(settings, settings.fontSize);
          }
          if (from < 13) {
            await m.addColumn(products, products.variantSize);
          }
          // from < 14: Products.variantGroup was dropped — no migration step
          // (see the one-time exception noted on schemaVersion above).
          if (from < 15) {
            await m.createTable(customerDebtAdjustments);
          }
          if (from < 16) {
            await m.addColumn(settings, settings.backupDestination);
            await m.addColumn(settings, settings.lastAutoBackupAt);
          }
        },
        beforeOpen: (details) async {
          // Optional: enable foreign keys or run startup checks here if needed.
          // Left as a no-op for now — this app never enforced FK constraints at
          // the SQLite level, so turning that on retroactively could reject
          // writes against pre-existing data that predates strict enforcement.
        },
      );
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