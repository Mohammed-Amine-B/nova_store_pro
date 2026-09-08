import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(
    const Constant('general'),
  )(); // 'product_to_add' | 'customer_request' | 'general'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
