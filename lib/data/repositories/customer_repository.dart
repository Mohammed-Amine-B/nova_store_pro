import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';
import 'activity_log_repository.dart';

class CustomerWithBalance {
  final Customer customer;
  final double balance;
  CustomerWithBalance(this.customer, this.balance);
}

class CustomerRepository {
  final AppDatabase db;
  CustomerRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  Future<List<Customer>> getAllActive() async {
    return (db.select(db.customers)..where((c) => c.isArchived.equals(false))).get();
  }

  Future<List<Customer>> getArchived() async {
    return (db.select(db.customers)..where((c) => c.isArchived.equals(true))).get();
  }

  Future<int> add({required String name, String? phone, String? note}) async {
    final id = await db.into(db.customers).insert(CustomersCompanion.insert(
          name: name.trim(),
          phone: Value(phone?.trim()),
          note: Value(note?.trim()),
        ));
    await _activityLog.log('customer', 'created', entityName: name.trim());
    return id;
  }

  Future<void> update({
    required int id,
    required String name,
    String? phone,
    String? note,
  }) async {
    await (db.update(db.customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(
        name: Value(name.trim()),
        phone: Value(phone?.trim()),
        note: Value(note?.trim()),
      ),
    );
    await _activityLog.log('customer', 'updated', entityName: name.trim());
  }

  /// Customers are archived, never hard-deleted.
  Future<void> archive(int id) async {
    final customer = await (db.select(db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
    await (db.update(db.customers)..where((c) => c.id.equals(id)))
        .write(const CustomersCompanion(isArchived: Value(true)));
    await _activityLog.log('customer', 'archived', entityName: customer?.name, refId: id);
  }

  Future<void> unarchive(int id) async {
    final customer = await (db.select(db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
    await (db.update(db.customers)..where((c) => c.id.equals(id)))
        .write(const CustomersCompanion(isArchived: Value(false)));
    await _activityLog.log('customer', 'restored', entityName: customer?.name, refId: id);
  }

  Future<Customer?> getById(int id) async {
    return (db.select(db.customers)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Newest first.
  Future<List<Sale>> getSalesForCustomer(int customerId) async {
    return (db.select(db.sales)
          ..where((s) => s.customerId.equals(customerId))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  /// Newest first.
  Future<List<DebtPayment>> getPaymentsForCustomer(int customerId) async {
    return (db.select(db.debtPayments)
          ..where((p) => p.customerId.equals(customerId))
          ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
        .get();
  }

  Future<double> getRemainingBalance(int customerId) async {
    final sales = await getSalesForCustomer(customerId);
    final owedFromSales = sales.fold<double>(0, (sum, s) => sum + (s.totalAmount - s.amountPaid));
    final payments = await getPaymentsForCustomer(customerId);
    final paidAfterSale = payments.fold<double>(0, (sum, p) => sum + p.amount);
    return roundMoney(owedFromSales - paidAfterSale);
  }

  Future<int> recordPayment({
    required int customerId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    final id = await db.into(db.debtPayments).insert(DebtPaymentsCompanion.insert(
          customerId: customerId,
          amount: roundMoney(amount),
          paymentDate: paymentDate,
          note: Value(note?.trim()),
        ));
    final customer = await (db.select(db.customers)..where((c) => c.id.equals(customerId))).getSingleOrNull();
    await _activityLog.log('payment', 'created', amount: roundMoney(amount), entityName: customer?.name, refId: customerId);
    return id;
  }

  /// Active customers with their computed remaining balance, sorted by balance descending.
  Future<List<CustomerWithBalance>> getAllWithBalances() async {
    final customers = await getAllActive();
    final result = <CustomerWithBalance>[];
    for (final c in customers) {
      final balance = await getRemainingBalance(c.id);
      result.add(CustomerWithBalance(c, balance));
    }
    result.sort((a, b) => b.balance.compareTo(a.balance));
    return result;
  }

  /// Sum of every positive active-customer balance — how much customers owe the shop overall.
  Future<double> getTotalOutstandingBalance() async {
    final all = await getAllWithBalances();
    final total = all.fold<double>(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));
    return roundMoney(total);
  }
}
