import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';
import 'activity_log_repository.dart';

class SaleLineInput {
  final int productId;
  final double quantity;
  final double unitPrice;
  SaleLineInput({required this.productId, required this.quantity, required this.unitPrice});
}

class InsufficientStockException implements Exception {
  final String productName;
  final double requested;
  final double available;
  InsufficientStockException(this.productName, this.requested, this.available);

  @override
  String toString() =>
      'Not enough stock for $productName: requested $requested, only $available available';
}

class SalesRepository {
  final AppDatabase db;
  SalesRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  Future<List<Sale>> getSalesForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (db.select(db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerThanValue(end) &
              s.source.equals('quick'))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  /// Most recent first — used by the Start Return flow to find the original sale.
  Future<List<Sale>> getRecentSales({int limit = 20}) async {
    return (db.select(db.sales)
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<List<SaleItem>> getItemsForSale(int saleId) async {
    return (db.select(db.saleItems)..where((i) => i.saleId.equals(saleId))).get();
  }

  /// Pre-validates that every line has enough stock, throwing InsufficientStockException
  /// on the first line that doesn't. Called before starting the write transaction.
  Future<void> _validateStock(List<SaleLineInput> lines) async {
    for (final line in lines) {
      final product = await (db.select(db.products)..where((p) => p.id.equals(line.productId))).getSingle();
      if (product.stockQuantity < line.quantity) {
        throw InsufficientStockException(product.name, line.quantity, product.stockQuantity);
      }
    }
  }

  /// Consumes `quantity` units from a product's batches, oldest first (FIFO).
  /// Returns the list of (batchId, quantityTaken, buyPrice) consumed, and the blended unit cost.
  Future<({List<(int, double, double)> consumed, double unitCost})> _consumeFifo(
    int productId,
    double quantity,
  ) async {
    final batches = await (db.select(db.productBatches)
          ..where((b) => b.productId.equals(productId) & b.quantity.isBiggerThanValue(0))
          ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
        .get();

    var remaining = quantity;
    var totalCost = 0.0;
    final consumed = <(int, double, double)>[];

    for (final batch in batches) {
      if (remaining <= 0) break;
      final take = remaining < batch.quantity ? remaining : batch.quantity;
      consumed.add((batch.id, take, batch.buyPrice));
      totalCost += take * batch.buyPrice;
      remaining -= take;

      await (db.update(db.productBatches)..where((b) => b.id.equals(batch.id)))
          .write(ProductBatchesCompanion(quantity: Value(roundQuantity(batch.quantity - take))));
    }

    final unitCost = quantity > 0 ? roundMoney(totalCost / quantity) : 0.0;
    return (consumed: consumed, unitCost: unitCost);
  }

  /// Creates a sale with one or more lines, atomically. Validates stock for ALL
  /// lines before touching anything, so a bad line never partially applies.
  Future<int> createSale({
    required DateTime date,
    required List<SaleLineInput> lines,
    int? customerId,
    String paymentMethod = 'cash',
    double? amountPaid,
    String source = 'quick',
  }) async {
    if ((paymentMethod == 'credit' || paymentMethod == 'split') && customerId == null) {
      throw Exception('A customer must be selected for credit or split payments');
    }
    await _validateStock(lines);

    return db.transaction(() async {
      var totalAmount = 0.0;
      var totalProfit = 0.0;

      final saleId = await db.into(db.sales).insert(SalesCompanion.insert(date: date, source: Value(source)));

      for (final line in lines) {
        final result = await _consumeFifo(line.productId, line.quantity);

        final saleItemId = await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
              saleId: saleId,
              productId: line.productId,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              unitCost: result.unitCost,
            ));

        for (final (batchId, qty, buyPrice) in result.consumed) {
          await db.into(db.saleItemBatches).insert(SaleItemBatchesCompanion.insert(
                saleItemId: saleItemId,
                batchId: batchId,
                quantity: qty,
                buyPrice: buyPrice,
              ));
        }

        final product = await (db.select(db.products)..where((p) => p.id.equals(line.productId))).getSingle();
        await (db.update(db.products)..where((p) => p.id.equals(line.productId))).write(
          ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity - line.quantity))),
        );

        await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
              productId: line.productId,
              direction: 'out',
              type: 'sale',
              quantity: roundQuantity(line.quantity),
              note: Value('Sold ${line.quantity} units'),
            ));

        totalAmount += line.quantity * line.unitPrice;
        totalProfit += line.quantity * (line.unitPrice - result.unitCost);
      }

      totalAmount = roundMoney(totalAmount);
      totalProfit = roundMoney(totalProfit);
      final paid = roundMoney(amountPaid ?? totalAmount);

      await (db.update(db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          totalAmount: Value(totalAmount),
          totalProfit: Value(totalProfit),
          customerId: Value(customerId),
          paymentMethod: Value(paymentMethod),
          amountPaid: Value(paid),
        ),
      );

      String? customerName;
      if (customerId != null) {
        final customer = await (db.select(db.customers)..where((c) => c.id.equals(customerId))).getSingleOrNull();
        customerName = customer?.name;
      }
      await _activityLog.log('sale', 'created', amount: totalAmount, entityName: customerName, refId: saleId);

      return saleId;
    });
  }

  /// Edits a sale line: reverts its old stock consumption, then reapplies with
  /// the new quantity/price. Only quantity and unitPrice are editable.
  Future<void> updateSaleItem({
    required int saleItemId,
    required double newQuantity,
    required double newUnitPrice,
  }) async {
    final item = await (db.select(db.saleItems)..where((i) => i.id.equals(saleItemId))).getSingle();

    // Pre-validate the new quantity will fit, accounting for what we're about to give back.
    final oldBatches = await (db.select(db.saleItemBatches)..where((b) => b.saleItemId.equals(saleItemId))).get();
    final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
    final hypotheticalAvailable = product.stockQuantity + item.quantity; // as if reverted
    if (hypotheticalAvailable < newQuantity) {
      throw InsufficientStockException(product.name, newQuantity, hypotheticalAvailable);
    }

    await db.transaction(() async {
      // Revert: give quantity back to each batch it came from.
      for (final b in oldBatches) {
        final batch = await (db.select(db.productBatches)..where((pb) => pb.id.equals(b.batchId))).getSingle();
        await (db.update(db.productBatches)..where((pb) => pb.id.equals(b.batchId)))
            .write(ProductBatchesCompanion(quantity: Value(roundQuantity(batch.quantity + b.quantity))));
      }
      await (db.delete(db.saleItemBatches)..where((b) => b.saleItemId.equals(saleItemId))).go();
      await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity + item.quantity))),
      );

      // Reapply with new quantity/price.
      final result = await _consumeFifo(item.productId, newQuantity);
      for (final (batchId, qty, buyPrice) in result.consumed) {
        await db.into(db.saleItemBatches).insert(SaleItemBatchesCompanion.insert(
              saleItemId: saleItemId,
              batchId: batchId,
              quantity: qty,
              buyPrice: buyPrice,
            ));
      }

      final refreshedProduct = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
      await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(refreshedProduct.stockQuantity - newQuantity))),
      );

      await (db.update(db.saleItems)..where((i) => i.id.equals(saleItemId))).write(
        SaleItemsCompanion(
          quantity: Value(roundQuantity(newQuantity)),
          unitPrice: Value(roundMoney(newUnitPrice)),
          unitCost: Value(result.unitCost),
        ),
      );

      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            productId: item.productId,
            direction: 'out',
            type: 'sale',
            quantity: roundQuantity(newQuantity),
            note: Value('Sale edited: now $newQuantity units @ $newUnitPrice DA'),
          ));

      // Recompute sale totals from all items.
      await _recomputeSaleTotals(item.saleId);

      await _activityLog.log('sale', 'updated', refId: item.saleId);
    });
  }

  /// Deletes a sale entirely: restores stock, logs sale_delete movements, hard-deletes rows.
  Future<void> deleteSale(int saleId) async {
    await db.transaction(() async {
      final items = await (db.select(db.saleItems)..where((i) => i.saleId.equals(saleId))).get();

      for (final item in items) {
        final batches = await (db.select(db.saleItemBatches)..where((b) => b.saleItemId.equals(item.id))).get();
        for (final b in batches) {
          final batch = await (db.select(db.productBatches)..where((pb) => pb.id.equals(b.batchId))).getSingle();
          await (db.update(db.productBatches)..where((pb) => pb.id.equals(b.batchId)))
              .write(ProductBatchesCompanion(quantity: Value(roundQuantity(batch.quantity + b.quantity))));
        }
        final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
        await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
          ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity + item.quantity))),
        );
        await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
              productId: item.productId,
              direction: 'in',
              type: 'sale_delete',
              quantity: roundQuantity(item.quantity),
              note: Value('Sale deleted — ${item.quantity} units restored'),
            ));
      }

      await (db.delete(db.saleItemBatches)
            ..where((b) => b.saleItemId.isInQuery(
                db.selectOnly(db.saleItems)..addColumns([db.saleItems.id])
                  ..where(db.saleItems.saleId.equals(saleId)))))
          .go();
      await (db.delete(db.saleItems)..where((i) => i.saleId.equals(saleId))).go();
      await (db.delete(db.sales)..where((s) => s.id.equals(saleId))).go();

      await _activityLog.log('sale', 'deleted', refId: saleId);
    });
  }

  Future<void> _recomputeSaleTotals(int saleId) async {
    final items = await (db.select(db.saleItems)..where((i) => i.saleId.equals(saleId))).get();
    final totalAmount = roundMoney(items.fold<double>(0, (sum, i) => sum + i.quantity * i.unitPrice));
    final totalProfit =
        roundMoney(items.fold<double>(0, (sum, i) => sum + i.quantity * (i.unitPrice - i.unitCost)));
    await (db.update(db.sales)..where((s) => s.id.equals(saleId))).write(
      SalesCompanion(totalAmount: Value(totalAmount), totalProfit: Value(totalProfit)),
    );
  }

  Future<Product> getProduct(int productId) async {
    return (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
  }

  Future<List<Product>> searchProducts(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return (db.select(db.products)
          ..where((p) =>
              p.isArchived.equals(false) &
              (p.name.lower().like('%$q%') |
                  p.code.lower().like('%$q%') |
                  p.barcode.lower().like('%$q%')))
          ..limit(6))
        .get();
  }

  /// Groups all past sales by day (excluding today), newest first.
  Future<List<({DateTime date, double revenue, double profit, int count})>> getArchiveDays() async {
    final allSales = await (db.select(db.sales)..where((s) => s.source.equals('quick'))).get();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final map = <DateTime, (double, double, int)>{}; // dayKey -> (revenue, profit, count)
    for (final s in allSales) {
      final dayKey = DateTime(s.date.year, s.date.month, s.date.day);
      if (dayKey == todayStart) continue;
      final existing = map[dayKey] ?? (0.0, 0.0, 0);
      map[dayKey] = (existing.$1 + s.totalAmount, existing.$2 + s.totalProfit, existing.$3 + 1);
    }

    final result = map.entries
        .map((e) => (date: e.key, revenue: e.value.$1, profit: e.value.$2, count: e.value.$3))
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return result;
  }

  /// All Customer Sale invoices (one row per sale), newest first, with the customer's name resolved.
  Future<List<({Sale sale, String customerName})>> getCustomerSaleInvoices() async {
    final sales = await (db.select(db.sales)
          ..where((s) => s.source.equals('customer_sale'))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
    final customers = await db.select(db.customers).get();
    final nameOf = {for (final c in customers) c.id: c.name};
    return sales
        .map((s) => (sale: s, customerName: s.customerId != null ? (nameOf[s.customerId] ?? 'Unknown') : 'Walk-in'))
        .toList();
  }

    Future<({double revenue, double profit})> getMonthSummary() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final sales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(start) & s.date.isSmallerThanValue(end)))
        .get();
    final revenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final profit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    return (revenue: roundMoney(revenue), profit: roundMoney(profit));
  }

  Future<({double revenue, double profit})> getYearSummary() async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    final sales = await (db.select(db.sales)
          ..where((s) => s.date.isBiggerOrEqualValue(start) & s.date.isSmallerThanValue(end)))
        .get();
    final revenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final profit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    return (revenue: roundMoney(revenue), profit: roundMoney(profit));
  }

    Future<Sale> getSaleById(int id) async {
    return (db.select(db.sales)..where((s) => s.id.equals(id))).getSingle();
  }


    /// Adds a brand-new line to an already-existing sale. Runs the same FIFO
  /// consumption as a fresh sale, then recomputes the sale's totals.
  Future<void> addSaleLine({
    required int saleId,
    required int productId,
    required double quantity,
    required double unitPrice,
  }) async {
    final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
    if (product.stockQuantity < quantity) {
      throw InsufficientStockException(product.name, quantity, product.stockQuantity);
    }

    await db.transaction(() async {
      final result = await _consumeFifo(productId, quantity);

      final saleItemId = await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
            saleId: saleId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            unitCost: result.unitCost,
          ));

      for (final (batchId, qty, buyPrice) in result.consumed) {
        await db.into(db.saleItemBatches).insert(SaleItemBatchesCompanion.insert(
              saleItemId: saleItemId,
              batchId: batchId,
              quantity: qty,
              buyPrice: buyPrice,
            ));
      }

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity - quantity))),
      );

      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            productId: productId,
            direction: 'out',
            type: 'sale',
            quantity: roundQuantity(quantity),
            note: Value('Sold $quantity units (added to existing sale)'),
          ));

      await _recomputeSaleTotals(saleId);
    });
  }

  /// Updates how much of a sale has been paid, auto-deriving the payment
  /// method label from the new amount (full = cash, zero = credit, partial = split).
  Future<void> updateAmountPaid({
    required int saleId,
    required double newAmountPaid,
  }) async {
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
    final paid = roundMoney(newAmountPaid);
    if (paid < 0 || paid > sale.totalAmount) {
      throw Exception('Amount paid must be between 0 and the total');
    }
    final method = paid >= sale.totalAmount ? 'cash' : (paid <= 0 ? 'credit' : 'split');
    await (db.update(db.sales)..where((s) => s.id.equals(saleId))).write(
      SalesCompanion(amountPaid: Value(paid), paymentMethod: Value(method)),
    );
  }

}