import 'package:drift/drift.dart';
import '../database/database.dart';
import 'activity_log_repository.dart';
import 'customer_repository.dart';
import 'supplier_repository.dart';

class DashboardSummary {
  final int productCount;
  final int categoryCount;
  final double todaySalesTotal;
  final int todaySalesCount;
  final List<Product> lowStockProducts;
  final double customersOwed;
  final double owedToSuppliers;
  final List<ActivityLogData> recentActivity;

  DashboardSummary({
    required this.productCount,
    required this.categoryCount,
    required this.todaySalesTotal,
    required this.todaySalesCount,
    required this.lowStockProducts,
    required this.customersOwed,
    required this.owedToSuppliers,
    required this.recentActivity,
  });
}

class DashboardRepository {
  final AppDatabase db;
  DashboardRepository(this.db);
  late final CustomerRepository _customerRepo = CustomerRepository(db);
  late final SupplierRepository _supplierRepo = SupplierRepository(db);
  late final ActivityLogRepository _activityLogRepo = ActivityLogRepository(db);

  Future<DashboardSummary> getSummary() async {
    final productCount = await (db.selectOnly(db.products)
          ..addColumns([db.products.id.count()])
          ..where(db.products.isArchived.equals(false)))
        .map((row) => row.read(db.products.id.count()) ?? 0)
        .getSingle();

    final categoryCount = await (db.selectOnly(db.categories)
          ..addColumns([db.categories.id.count()]))
        .map((row) => row.read(db.categories.id.count()) ?? 0)
        .getSingle();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todaySales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(startOfDay) & s.date.isSmallerThanValue(endOfDay)))
        .get();

    final todaySalesTotal = todaySales.fold<double>(0, (sum, s) => sum + s.totalAmount);

   final lowStock = await (db.select(db.products)
          ..where((p) => p.isArchived.equals(false) & p.stockQuantity.isSmallerOrEqual(p.minStock)))
        .get();
    // NOTE: see question below — minStock comparison needs a column-to-column check

    final customersOwed = await _customerRepo.getTotalOutstandingBalance();
    final owedToSuppliers = await _supplierRepo.getTotalOutstandingOwed();
    final recentActivity = await _activityLogRepo.getEntries(limit: 5);

    return DashboardSummary(
      productCount: productCount,
      categoryCount: categoryCount,
      todaySalesTotal: todaySalesTotal,
      todaySalesCount: todaySales.length,
      lowStockProducts: lowStock,
      customersOwed: customersOwed,
      owedToSuppliers: owedToSuppliers,
      recentActivity: recentActivity,
    );
  }
}