import 'package:drift/drift.dart';
import 'returns_table.dart';
import 'sale_items_table.dart';

class ReturnItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get returnId => integer().references(Returns, #id)();
  IntColumn get saleItemId => integer().references(SaleItems, #id)();
  RealColumn get quantity => real()();
  RealColumn get refundAmount => real()();
}
