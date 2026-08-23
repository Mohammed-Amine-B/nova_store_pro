import 'package:drift/drift.dart';
import 'purchases_table.dart';
import '../tables/products_table.dart';
import 'product_batches_table.dart';

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get buyPrice => real()();
  IntColumn get batchId => integer().nullable().references(ProductBatches, #id)();
}
