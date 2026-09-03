import 'package:drift/drift.dart';
import 'customers_table.dart';

// A manually-entered debt amount not tied to any sale — e.g. an opening
// balance the customer already owed before this app was used.
class CustomerDebtAdjustments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  RealColumn get amount => real()(); // always positive — adds to what they owe
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
