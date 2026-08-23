import 'package:drift/drift.dart';
import 'sales_table.dart';

// reason: 'damaged' | 'wrong_item' | 'changed_mind' | 'other'
class Returns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  RealColumn get totalRefunded => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
