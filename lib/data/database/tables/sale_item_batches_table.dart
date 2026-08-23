import 'package:drift/drift.dart';
import 'sale_items_table.dart';
import 'product_batches_table.dart';

class SaleItemBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleItemId => integer().references(SaleItems, #id)();
  IntColumn get batchId => integer().references(ProductBatches, #id)();
  RealColumn get quantity => real()();
  RealColumn get buyPrice => real()(); // snapshot at time of sale
}