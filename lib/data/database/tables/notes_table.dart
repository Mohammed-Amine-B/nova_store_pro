import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(
    const Constant('general'),
  )(); // 'product_to_add' | 'customer_request' | 'general'
  // Purely informational — a personal reminder of what was sold/for how much.
  // NEVER counted in any revenue/profit calculation anywhere in the app.
  RealColumn get price => real().nullable()();
  RealColumn get quantity => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
