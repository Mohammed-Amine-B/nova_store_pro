import 'package:drift/drift.dart';
import 'customers_table.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // trading day this sale counts toward
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  RealColumn get totalProfit => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))(); // 'cash' | 'card' | 'credit' | 'split'
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('quick'))(); // 'quick' | 'customer_sale'
}