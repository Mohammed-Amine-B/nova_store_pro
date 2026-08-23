import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';
import 'activity_log_repository.dart';

class SupplierRepository {
  final AppDatabase db;
  SupplierRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  Future<List<Supplier>> getAllActive() async {
    return (db.select(db.suppliers)..where((s) => s.isArchived.equals(false))).get();
  }

  Future<List<Supplier>> getArchived() async {
    return (db.select(db.suppliers)..where((s) => s.isArchived.equals(true))).get();
  }

  Future<int> add({
    required String name,
    String? location,
    String? phone,
    String? note,
  }) async {
    final id = await db.into(db.suppliers).insert(SuppliersCompanion.insert(
          name: name.trim(),
          location: Value(location?.trim()),
          phone: Value(phone?.trim()),
          note: Value(note?.trim()),
        ));
    await _activityLog.log('supplier', 'created', entityName: name.trim());
    return id;
  }

  Future<void> update({
    required int id,
    required String name,
    String? location,
    String? phone,
    String? note,
  }) async {
    await (db.update(db.suppliers)..where((s) => s.id.equals(id))).write(
      SuppliersCompanion(
        name: Value(name.trim()),
        location: Value(location?.trim()),
        phone: Value(phone?.trim()),
        note: Value(note?.trim()),
      ),
    );
    await _activityLog.log('supplier', 'updated', entityName: name.trim());
  }

  /// Suppliers are archived, never hard-deleted.
  Future<void> archive(int id) async {
    final supplier = await (db.select(db.suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
    await (db.update(db.suppliers)..where((s) => s.id.equals(id)))
        .write(const SuppliersCompanion(isArchived: Value(true)));
    await _activityLog.log('supplier', 'archived', entityName: supplier?.name, refId: id);
  }

  Future<void> unarchive(int id) async {
    final supplier = await (db.select(db.suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
    await (db.update(db.suppliers)..where((s) => s.id.equals(id)))
        .write(const SuppliersCompanion(isArchived: Value(false)));
    await _activityLog.log('supplier', 'restored', entityName: supplier?.name, refId: id);
  }

  Future<Supplier?> getById(int id) async {
    return (db.select(db.suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<double> totalPurchasedFrom(int supplierId) async {
    final rows = await (db.selectOnly(db.purchases)
          ..addColumns([db.purchases.totalAmount])
          ..where(db.purchases.supplierId.equals(supplierId)))
        .get();
    var total = 0.0;
    for (final row in rows) {
      total += row.read(db.purchases.totalAmount) ?? 0;
    }
    return roundMoney(total);
  }

  Future<List<SupplierPayment>> getPaymentsForSupplier(int supplierId) async {
    return (db.select(db.supplierPayments)
          ..where((p) => p.supplierId.equals(supplierId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .get();
  }

  Future<double> getRemainingOwed(int supplierId) async {
    final purchases = await (db.select(db.purchases)..where((p) => p.supplierId.equals(supplierId))).get();
    final owed = purchases.fold<double>(0, (sum, p) => sum + (p.totalAmount - p.amountPaid));
    final payments = await getPaymentsForSupplier(supplierId);
    final paid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    return roundMoney(owed - paid);
  }

  /// Sum of every positive active-supplier owed amount — how much the shop owes suppliers overall.
  Future<double> getTotalOutstandingOwed() async {
    final suppliers = await getAllActive();
    var total = 0.0;
    for (final s in suppliers) {
      final owed = await getRemainingOwed(s.id);
      if (owed > 0) total += owed;
    }
    return roundMoney(total);
  }

  Future<void> recordPayment({
    required int supplierId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    await db.into(db.supplierPayments).insert(SupplierPaymentsCompanion.insert(
          supplierId: supplierId,
          amount: roundMoney(amount),
          paymentDate: paymentDate,
          note: Value(note),
        ));
    final supplier = await (db.select(db.suppliers)..where((s) => s.id.equals(supplierId))).getSingleOrNull();
    await _activityLog.log('payment', 'created', amount: roundMoney(amount), entityName: supplier?.name, refId: supplierId);
  }
}
