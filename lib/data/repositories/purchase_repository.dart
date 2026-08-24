import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart';
import 'activity_log_repository.dart';

class PurchaseLineInput {
  final int productId;
  final double quantity;
  final double buyPrice;
  final double? sellingPrice;
  PurchaseLineInput({required this.productId, required this.quantity, required this.buyPrice, this.sellingPrice});
}

class PurchaseRepository {
  final AppDatabase db;
  PurchaseRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  /// Newest first.
  Future<List<Purchase>> getAllPurchases() async {
    return (db.select(db.purchases)
          ..orderBy([(p) => OrderingTerm.desc(p.purchaseDate)]))
        .get();
  }

  /// All purchases across every supplier, newest first, with the supplier's name resolved.
  Future<List<({Purchase purchase, String supplierName})>> getAllPurchaseRecords() async {
    final purchases = await getAllPurchases(); // reuse the existing method
    final suppliers = await db.select(db.suppliers).get();
    final nameOf = {for (final s in suppliers) s.id: s.name};
    return purchases.map((p) => (purchase: p, supplierName: nameOf[p.supplierId] ?? 'Unknown')).toList();
  }

  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) async {
    return (db.select(db.purchaseItems)..where((i) => i.purchaseId.equals(purchaseId))).get();
  }

  Future<List<Purchase>> getPurchasesForSupplier(int supplierId) async {
    return (db.select(db.purchases)
          ..where((p) => p.supplierId.equals(supplierId))
          ..orderBy([(p) => OrderingTerm.desc(p.purchaseDate)]))
        .get();
  }

  /// Creates a purchase with one or more lines, atomically. For each line, reuses
  /// the latest product batch if the buy price matches (same rule as
  /// ProductRepository.addStock), else creates a new batch, updates cached stock,
  /// and logs a stock movement.
  Future<int> createPurchase({
    required int supplierId,
    required DateTime purchaseDate,
    required List<PurchaseLineInput> lines,
    double? amountPaid,
  }) async {
    return db.transaction(() async {
      var totalAmount = 0.0;

      final purchaseId = await db.into(db.purchases).insert(PurchasesCompanion.insert(
            supplierId: supplierId,
            purchaseDate: purchaseDate,
          ));

      for (final line in lines) {
        final product = await (db.select(db.products)..where((p) => p.id.equals(line.productId))).getSingle();
        final latestBatch = await (db.select(db.productBatches)
              ..where((b) => b.productId.equals(line.productId))
              ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
              ..limit(1))
            .getSingleOrNull();

        int batchId;
        if (latestBatch != null && latestBatch.buyPrice == line.buyPrice) {
          // Top up the existing latest batch instead of creating a new one.
          batchId = latestBatch.id;
          await (db.update(db.productBatches)..where((b) => b.id.equals(batchId)))
              .write(ProductBatchesCompanion(
                  quantity: Value(roundQuantity(latestBatch.quantity + line.quantity))));
        } else {
          batchId = await db.into(db.productBatches).insert(ProductBatchesCompanion.insert(
                productId: line.productId,
                buyPrice: roundMoney(line.buyPrice),
                quantity: roundQuantity(line.quantity),
                purchaseDate: purchaseDate,
              ));
        }

        // Update cached stock total.
        await (db.update(db.products)..where((p) => p.id.equals(line.productId))).write(
          ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity + line.quantity))),
        );
        if (line.sellingPrice != null) {
          await (db.update(db.products)..where((p) => p.id.equals(line.productId)))
              .write(ProductsCompanion(sellingPrice: Value(roundMoney(line.sellingPrice!))));
        }
        await db.into(db.purchaseItems).insert(PurchaseItemsCompanion.insert(
              purchaseId: purchaseId,
              productId: line.productId,
              quantity: roundQuantity(line.quantity),
              buyPrice: roundMoney(line.buyPrice),
              batchId: Value(batchId),
            ));

        await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
              productId: line.productId,
              batchId: Value(batchId),
              direction: 'in',
              type: 'stock_add',
              quantity: roundQuantity(line.quantity),
              note: Value('Purchased ${line.quantity} units @ ${line.buyPrice} DA'),
            ));

        totalAmount += line.quantity * line.buyPrice;
      }

      final paid = roundMoney(amountPaid ?? totalAmount);
      await (db.update(db.purchases)..where((p) => p.id.equals(purchaseId)))
          .write(PurchasesCompanion(totalAmount: Value(roundMoney(totalAmount)), amountPaid: Value(paid)));

      final supplier = await (db.select(db.suppliers)..where((s) => s.id.equals(supplierId))).getSingleOrNull();
      await _activityLog.log('purchase', 'created',
          amount: roundMoney(totalAmount), entityName: supplier?.name, refId: purchaseId);

      return purchaseId;
    });
  }

  Future<Purchase> getPurchaseById(int id) async {
    return (db.select(db.purchases)..where((p) => p.id.equals(id))).getSingle();
  }

  /// Deletes a purchase entirely: reverses stock for every line, then hard-deletes the rows.
  Future<void> deletePurchase(int purchaseId) async {
    await db.transaction(() async {
      final items = await (db.select(db.purchaseItems)..where((i) => i.purchaseId.equals(purchaseId))).get();

      for (final item in items) {
        if (item.batchId != null) {
          final batch = await (db.select(db.productBatches)..where((b) => b.id.equals(item.batchId!))).getSingleOrNull();
          if (batch != null) {
            await (db.update(db.productBatches)..where((b) => b.id.equals(batch.id)))
                .write(ProductBatchesCompanion(quantity: Value(roundQuantity(batch.quantity - item.quantity))));
          }
        }
        final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
        await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
          ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity - item.quantity))),
        );
        await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
              productId: item.productId,
              batchId: Value(item.batchId),
              direction: 'out',
              type: 'purchase_delete',
              quantity: roundQuantity(item.quantity),
              note: Value('Purchase deleted — ${item.quantity} units reversed'),
            ));
      }

      await (db.delete(db.purchaseItems)..where((i) => i.purchaseId.equals(purchaseId))).go();
      await (db.delete(db.purchases)..where((p) => p.id.equals(purchaseId))).go();
    });
  }

  Future<void> addPurchaseLine({
    required int purchaseId,
    required int productId,
    required double quantity,
    required double buyPrice,
    double? sellingPrice,
  }) async {
    await db.transaction(() async {
      final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
      final latestBatch = await (db.select(db.productBatches)
            ..where((b) => b.productId.equals(productId))
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
            ..limit(1))
          .getSingleOrNull();

      int batchId;
      if (latestBatch != null && latestBatch.buyPrice == buyPrice) {
        batchId = latestBatch.id;
        await (db.update(db.productBatches)..where((b) => b.id.equals(batchId)))
            .write(ProductBatchesCompanion(quantity: Value(roundQuantity(latestBatch.quantity + quantity))));
      } else {
        batchId = await db.into(db.productBatches).insert(ProductBatchesCompanion.insert(
              productId: productId,
              buyPrice: roundMoney(buyPrice),
              quantity: roundQuantity(quantity),
              purchaseDate: DateTime.now(),
            ));
      }

      if (sellingPrice != null) {
        await (db.update(db.products)..where((p) => p.id.equals(productId)))
            .write(ProductsCompanion(sellingPrice: Value(roundMoney(sellingPrice))));
      }

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity + quantity))),
      );

      await db.into(db.purchaseItems).insert(PurchaseItemsCompanion.insert(
            purchaseId: purchaseId,
            productId: productId,
            quantity: roundQuantity(quantity),
            buyPrice: roundMoney(buyPrice),
            batchId: Value(batchId),
          ));

      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            productId: productId,
            batchId: Value(batchId),
            direction: 'in',
            type: 'stock_add',
            quantity: roundQuantity(quantity),
            note: Value('Purchased $quantity units (added to existing purchase)'),
          ));

      await _recomputePurchaseTotal(purchaseId);

      await _activityLog.log('purchase', 'updated', refId: purchaseId);
    });
  }

  /// Deletes a single purchase line: reverses the batch quantity and cached
  /// stock it added, then recomputes the purchase total (clamping amountPaid
  /// down if it now exceeds the reduced total).
  Future<void> removePurchaseLine(int purchaseItemId) async {
    await db.transaction(() async {
      final item = await (db.select(db.purchaseItems)..where((i) => i.id.equals(purchaseItemId))).getSingle();

      if (item.batchId != null) {
        final batch = await (db.select(db.productBatches)..where((b) => b.id.equals(item.batchId!))).getSingleOrNull();
        if (batch != null) {
          await (db.update(db.productBatches)..where((b) => b.id.equals(batch.id)))
              .write(ProductBatchesCompanion(quantity: Value(roundQuantity(batch.quantity - item.quantity))));
        }
      }

      final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
      await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity - item.quantity))),
      );

      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            productId: item.productId,
            batchId: Value(item.batchId),
            direction: 'out',
            type: 'purchase_line_removed',
            quantity: roundQuantity(item.quantity),
            note: Value('Purchase line removed — ${item.quantity} units reversed'),
          ));

      await (db.delete(db.purchaseItems)..where((i) => i.id.equals(purchaseItemId))).go();
      await _recomputePurchaseTotal(item.purchaseId);

      final purchase = await (db.select(db.purchases)..where((p) => p.id.equals(item.purchaseId))).getSingle();
      if (purchase.amountPaid > purchase.totalAmount) {
        await (db.update(db.purchases)..where((p) => p.id.equals(item.purchaseId)))
            .write(PurchasesCompanion(amountPaid: Value(purchase.totalAmount)));
      }
    });
  }

  Future<void> updatePurchaseAmountPaid({
    required int purchaseId,
    required double newAmountPaid,
  }) async {
    final purchase = await (db.select(db.purchases)..where((p) => p.id.equals(purchaseId))).getSingle();
    final paid = roundMoney(newAmountPaid);
    if (paid < 0 || paid > purchase.totalAmount) {
      throw Exception('Amount paid must be between 0 and the total');
    }
    await (db.update(db.purchases)..where((p) => p.id.equals(purchaseId)))
        .write(PurchasesCompanion(amountPaid: Value(paid)));

    await _activityLog.log('purchase', 'updated', amount: paid, refId: purchaseId);
  }

  Future<void> _recomputePurchaseTotal(int purchaseId) async {
    final items = await (db.select(db.purchaseItems)..where((i) => i.purchaseId.equals(purchaseId))).get();
    final total = roundMoney(items.fold<double>(0, (sum, i) => sum + i.quantity * i.buyPrice));
    await (db.update(db.purchases)..where((p) => p.id.equals(purchaseId)))
        .write(PurchasesCompanion(totalAmount: Value(total)));
  }
}
