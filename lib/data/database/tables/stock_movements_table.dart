import 'package:drift/drift.dart';
import 'products_table.dart';
import 'product_batches_table.dart';

// direction: 'in' | 'out'
// type: 'stock_add' | 'sale' | 'sale_delete' | 'adjustment'
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get batchId =>
      integer().nullable().references(ProductBatches, #id)();
  TextColumn get direction => text().withLength(min: 2, max: 3)();
  TextColumn get type => text().withLength(min: 3, max: 20)();
  RealColumn get quantity => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}