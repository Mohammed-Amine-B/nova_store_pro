import 'package:drift/drift.dart';

// category: 'sale' | 'purchase' | 'return' | 'product' | 'category' | 'customer' | 'supplier' | 'payment'
// action: 'created' | 'updated' | 'deleted' | 'archived' | 'restored'
class ActivityLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get action => text()();
  RealColumn get amount => real().nullable()(); // money amount involved, if any
  TextColumn get entityLabel => text().nullable()(); // product/customer/supplier name, if any
  IntColumn get refId => integer().nullable()(); // sale id / purchase id / etc, if any
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
