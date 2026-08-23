import 'package:drift/drift.dart';
import '../database/database.dart';

class DashboardSummary {
  final int productCount;
  final int categoryCount;
  final double todaySalesTotal;
  final int todaySalesCount;
  final List<Product> lowStockProducts;

  DashboardSummary({
    required this.productCount,
    required this.categoryCount,
    required this.todaySalesTotal,
    required this.todaySalesCount,
    required this.lowStockProducts,
  });
}

class DashboardRepository {
  final AppDatabase db;
  DashboardRepository(this.db);

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

    return DashboardSummary(
      productCount: productCount,
      categoryCount: categoryCount,
      todaySalesTotal: todaySalesTotal,
      todaySalesCount: todaySales.length,
      lowStockProducts: lowStock,
    );
  }
}