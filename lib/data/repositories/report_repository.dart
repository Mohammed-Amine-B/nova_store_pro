import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';

class DailyPoint {
  final DateTime date;
  final double revenue;
  final double profit;
  DailyPoint({required this.date, required this.revenue, required this.profit});
}

class BestSellingProduct {
  final int productId;
  final String productName;
  final double unitsSold;
  final double revenue;
  BestSellingProduct({required this.productId, required this.productName, required this.unitsSold, required this.revenue});
}

class ReportRepository {
  final AppDatabase db;
  ReportRepository(this.db);

  /// Daily revenue/profit points between [start] (inclusive) and [end] (exclusive).
  Future<List<DailyPoint>> getDailySeries(DateTime start, DateTime end) async {
    final sales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(start) & s.date.isSmallerThanValue(end)))
        .get();

    final map = <DateTime, (double, double)>{};
    for (final s in sales) {
      final dayKey = DateTime(s.date.year, s.date.month, s.date.day);
      final existing = map[dayKey] ?? (0.0, 0.0);
      map[dayKey] = (existing.$1 + s.totalAmount, existing.$2 + s.totalProfit);
    }

    final result = map.entries
        .map((e) => DailyPoint(date: e.key, revenue: roundMoney(e.value.$1), profit: roundMoney(e.value.$2)))
        .toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  Future<List<BestSellingProduct>> getBestSellingProducts(DateTime start, DateTime end, {int limit = 10}) async {
    final sales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(start) & s.date.isSmallerThanValue(end)))
        .get();
    if (sales.isEmpty) return [];
    final saleIds = sales.map((s) => s.id).toSet();

    final allItems = await db.select(db.saleItems).get();
    final items = allItems.where((i) => saleIds.contains(i.saleId)).toList();

    final map = <int, (double, double)>{}; // productId -> (units, revenue)
    for (final i in items) {
      final existing = map[i.productId] ?? (0.0, 0.0);
      map[i.productId] = (existing.$1 + i.quantity, existing.$2 + (i.quantity * i.unitPrice));
    }

    final products = await db.select(db.products).get();
    final nameOf = {for (final p in products) p.id: p.name};

    final result = map.entries
        .map((e) => BestSellingProduct(
              productId: e.key,
              productName: nameOf[e.key] ?? 'Unknown',
              unitsSold: roundQuantity(e.value.$1),
              revenue: roundMoney(e.value.$2),
            ))
        .toList();
    result.sort((a, b) => b.revenue.compareTo(a.revenue));
    return result.take(limit).toList();
  }

  Future<double> getCurrentStockValue() async {
    final query = db.selectOnly(db.productBatches)
      ..addColumns([db.productBatches.buyPrice, db.productBatches.quantity]);
    final rows = await query.get();
    var total = 0.0;
    for (final row in rows) {
      final price = row.read(db.productBatches.buyPrice) ?? 0;
      final qty = row.read(db.productBatches.quantity) ?? 0;
      total += price * qty;
    }
    return roundMoney(total);
  }
}