import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';
import 'report_repository.dart';
import 'customer_repository.dart';
import 'supplier_repository.dart';

class ReorderSuggestion {
  final int productId;
  final String productName;
  final double currentStock;
  final double daysOfStockLeft;
  final double suggestedReorderQty;
  final String? suggestedSupplierName;
  final String unitType;
  ReorderSuggestion({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.daysOfStockLeft,
    required this.suggestedReorderQty,
    required this.suggestedSupplierName,
    required this.unitType,
  });
}

class InsightsRepository {
  final AppDatabase db;
  InsightsRepository(this.db);

  /// Products that are either running low relative to their own sales pace or
  /// already at/under their configured minimum stock threshold.
  Future<List<ReorderSuggestion>> getReorderSuggestions() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));

    final products = await (db.select(db.products)..where((p) => p.isArchived.equals(false))).get();

    final recentSales = await (db.select(db.sales)..where((s) => s.date.isBiggerOrEqualValue(start))).get();
    final recentSaleIds = recentSales.map((s) => s.id).toSet();
    final recentItems = recentSaleIds.isEmpty
        ? <SaleItem>[]
        : await (db.select(db.saleItems)..where((i) => i.saleId.isIn(recentSaleIds))).get();

    final soldByProduct = <int, double>{};
    for (final item in recentItems) {
      soldByProduct[item.productId] = (soldByProduct[item.productId] ?? 0) + item.quantity;
    }

    final suppliers = await db.select(db.suppliers).get();
    final supplierNameOf = {for (final s in suppliers) s.id: s.name};

    final results = <ReorderSuggestion>[];
    for (final product in products) {
      final totalSold = soldByProduct[product.id] ?? 0;
      final dailyVelocity = totalSold / 30;
      if (dailyVelocity == 0) continue;

      final daysOfStockLeft = product.stockQuantity / dailyVelocity;
      final lowStock = product.stockQuantity <= product.minStock;
      if (!(daysOfStockLeft < 14 || lowStock)) continue;

      final targetStock = (dailyVelocity * 30).ceil();
      final suggestedQty = max(1.0, targetStock - product.stockQuantity);

      String? supplierName;
      final joinQuery = db.select(db.purchaseItems).join([
        innerJoin(db.purchases, db.purchases.id.equalsExp(db.purchaseItems.purchaseId)),
      ])
        ..where(db.purchaseItems.productId.equals(product.id))
        ..orderBy([OrderingTerm.desc(db.purchases.purchaseDate)])
        ..limit(1);
      final row = await joinQuery.getSingleOrNull();
      if (row != null) {
        final supplierId = row.readTable(db.purchases).supplierId;
        supplierName = supplierNameOf[supplierId];
      }

      results.add(ReorderSuggestion(
        productId: product.id,
        productName: product.name,
        currentStock: roundQuantity(product.stockQuantity),
        daysOfStockLeft: roundQuantity(daysOfStockLeft),
        suggestedReorderQty: roundQuantity(suggestedQty),
        suggestedSupplierName: supplierName,
        unitType: product.unitType,
      ));
    }

    results.sort((a, b) => a.daysOfStockLeft.compareTo(b.daysOfStockLeft));
    return results;
  }

  /// Simple 7-day moving-average projection — not a fitted trend line, just an
  /// honest extrapolation of recent daily revenue.
  Future<({double nextWeekEstimate, double nextMonthEstimate})> getSalesForecast() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final end = today.add(const Duration(days: 1));

    final series = await ReportRepository(db).getDailySeries(start, end);
    final totalRevenue = series.fold<double>(0, (sum, p) => sum + p.revenue);
    final avgDailyRevenue = totalRevenue / 7;

    return (
      nextWeekEstimate: roundMoney(avgDailyRevenue * 7),
      nextMonthEstimate: roundMoney(avgDailyRevenue * 30),
    );
  }

  /// Flags today's revenue-so-far as unusually low or high versus the last 30
  /// days (excluding today). Returns null when there's no history to compare
  /// against, or when today isn't actually notable.
  Future<({bool isAnomaly, bool isLow, double todayRevenue, double avgRevenue})?> getTodayAnomaly() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final historyStart = todayStart.subtract(const Duration(days: 30));

    final todaySales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(todayStart) & s.date.isSmallerThanValue(todayEnd)))
        .get();
    final todayRevenue = roundMoney(todaySales.fold<double>(0, (sum, s) => sum + s.totalAmount));

    final historySales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(historyStart) & s.date.isSmallerThanValue(todayStart)))
        .get();
    final avgRevenue = roundMoney(historySales.fold<double>(0, (sum, s) => sum + s.totalAmount) / 30);

    if (avgRevenue == 0) return null;

    final isAnomaly = todayRevenue < avgRevenue * 0.5 || todayRevenue > avgRevenue * 1.5;
    if (!isAnomaly) return null;

    return (
      isAnomaly: true,
      isLow: todayRevenue < avgRevenue,
      todayRevenue: todayRevenue,
      avgRevenue: avgRevenue,
    );
  }

  /// Active products in stock with zero units sold in the last 30 days.
  Future<List<Product>> getStagnantProducts() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));

    final products = await (db.select(db.products)
          ..where((p) => p.isArchived.equals(false) & p.stockQuantity.isBiggerThanValue(0)))
        .get();

    final recentSales = await (db.select(db.sales)..where((s) => s.date.isBiggerOrEqualValue(start))).get();
    final recentSaleIds = recentSales.map((s) => s.id).toSet();
    final soldProductIds = recentSaleIds.isEmpty
        ? <int>{}
        : (await (db.select(db.saleItems)..where((i) => i.saleId.isIn(recentSaleIds))).get())
            .map((i) => i.productId)
            .toSet();

    return products.where((p) => !soldProductIds.contains(p.id)).toList();
  }

  /// Suggests a selling price for a new product based on the average markup
  /// (over each product's latest batch buy price) of other active, already
  /// priced products in the same category. Null if there's nothing to base it on.
  Future<double?> suggestSellingPrice(int categoryId, double buyPrice) async {
    final products = await (db.select(db.products)
          ..where((p) =>
              p.categoryId.equals(categoryId) & p.isArchived.equals(false) & p.sellingPrice.isNotNull()))
        .get();

    final markups = <double>[];
    for (final product in products) {
      final latestBatch = await (db.select(db.productBatches)
            ..where((b) => b.productId.equals(product.id))
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      if (latestBatch == null || latestBatch.buyPrice <= 0) continue;
      markups.add((product.sellingPrice! - latestBatch.buyPrice) / latestBatch.buyPrice);
    }

    if (markups.isEmpty) return null;
    final avgMarkup = markups.reduce((a, b) => a + b) / markups.length;
    return roundMoney(buyPrice * (1 + avgMarkup));
  }

  /// Customers who owe money but haven't shown any activity — a payment, or
  /// a customer-sale purchase that itself left a balance — in over 30 days.
  /// "Last activity" falls back to the customer's createdAt if they have
  /// neither. Sorted oldest-activity-first (most overdue first).
  Future<List<({Customer customer, double balance, DateTime lastActivity})>>
      getOldDebtCustomers() async {
    final customerRepo = CustomerRepository(db);
    final customers = await customerRepo.getAllActive();
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    final results = <({Customer customer, double balance, DateTime lastActivity})>[];
    for (final customer in customers) {
      final balance = await customerRepo.getRemainingBalance(customer.id);
      if (balance <= 0) continue;

      final sales = await customerRepo.getSalesForCustomer(customer.id);
      DateTime? lastSaleWithBalance;
      for (final s in sales) {
        if (s.source != 'customer_sale') continue;
        if (s.totalAmount - s.amountPaid <= 0) continue;
        if (lastSaleWithBalance == null || s.date.isAfter(lastSaleWithBalance)) {
          lastSaleWithBalance = s.date;
        }
      }

      final payments = await customerRepo.getPaymentsForCustomer(customer.id);
      DateTime? lastPayment;
      for (final p in payments) {
        if (lastPayment == null || p.paymentDate.isAfter(lastPayment)) {
          lastPayment = p.paymentDate;
        }
      }

      DateTime lastActivity;
      if (lastSaleWithBalance != null && lastPayment != null) {
        lastActivity =
            lastSaleWithBalance.isAfter(lastPayment) ? lastSaleWithBalance : lastPayment;
      } else {
        lastActivity = lastSaleWithBalance ?? lastPayment ?? customer.createdAt;
      }

      if (lastActivity.isBefore(cutoff)) {
        results.add((customer: customer, balance: roundMoney(balance), lastActivity: lastActivity));
      }
    }

    results.sort((a, b) => a.lastActivity.compareTo(b.lastActivity));
    return results;
  }

  /// Suppliers with an outstanding balance, biggest-owed first — who to
  /// prioritize paying.
  Future<List<({Supplier supplier, double owed})>> getSupplierPriorityPayments() async {
    final supplierRepo = SupplierRepository(db);
    final suppliers = await supplierRepo.getAllActive();

    final results = <({Supplier supplier, double owed})>[];
    for (final supplier in suppliers) {
      final owed = await supplierRepo.getRemainingOwed(supplier.id);
      if (owed > 0) {
        results.add((supplier: supplier, owed: roundMoney(owed)));
      }
    }

    results.sort((a, b) => b.owed.compareTo(a.owed));
    return results;
  }
}
