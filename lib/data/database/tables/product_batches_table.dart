import 'package:drift/drift.dart';
import 'products_table.dart';

class ProductBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  RealColumn get buyPrice => real()();
  RealColumn get quantity => real()(); // remaining quantity
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}