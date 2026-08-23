import 'package:drift/drift.dart';
import 'categories_table.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get barcode => text().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  RealColumn get stockQuantity => real().withDefault(const Constant(0))();
  RealColumn get minStock => real().withDefault(const Constant(0))();
  TextColumn get unitType => text().withDefault(const Constant('piece'))();
  TextColumn get imagePath => text().nullable()(); // filename only, resolved against product_images/ at display time
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}