import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/rounding.dart' as r;
import 'activity_log_repository.dart';

class ReturnLineInput {
  final int saleItemId;
  final double quantity;
  ReturnLineInput({required this.saleItemId, required this.quantity});
}

class ReturnResult {
  final int returnId;
  final double totalRefunded;
  final double cashRefund; // 0 if the return only reduced debt / already-owed amount
  ReturnResult({required this.returnId, required this.totalRefunded, required this.cashRefund});
}

class ReturnRepository {
  final AppDatabase db;
  ReturnRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  Future<List<Return>> getReturnsForSale(int saleId) async {
    return (db.select(db.returns)..where((t) => t.saleId.equals(saleId))).get();
  }

  Future<List<Return>> getAllReturns() async {
    return (db.select(db.returns)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<ReturnResult> createReturn({
    required int saleId,
    required String reason,
    String? note,
    required List<ReturnLineInput> lines,
  }) async {
    return db.transaction(() async {
      double totalRefunded = 0;

      for (final line in lines) {
        final item = await (db.select(db.saleItems)..where((si) => si.id.equals(line.saleItemId))).getSingle();
        if (line.quantity <= 0 || line.quantity > item.quantity) {
          throw Exception('Invalid return quantity for this item');
        }

        final isDamaged = reason == 'damaged';

        // Restore stock proportionally to the batches this line originally consumed.
        // For damaged returns, the item isn't fit to sell again, so the batch/product
        // sellable quantities are left untouched — only the sale-item-to-batch
        // bookkeeping below is still updated.
        final batchLinks = await (db.select(db.saleItemBatches)
              ..where((b) => b.saleItemId.equals(line.saleItemId)))
            .get();
        final originalTotal = item.quantity; // quantity BEFORE this return is applied
        for (final link in batchLinks) {
          final restoreQty = r.roundQuantity(line.quantity * (link.quantity / originalTotal));
          if (restoreQty <= 0) continue;
          if (!isDamaged) {
            final batch = await (db.select(db.productBatches)..where((pb) => pb.id.equals(link.batchId))).getSingle();
            await (db.update(db.productBatches)..where((pb) => pb.id.equals(link.batchId)))
                .write(ProductBatchesCompanion(quantity: Value(r.roundQuantity(batch.quantity + restoreQty))));
          }
          await (db.update(db.saleItemBatches)..where((b) => b.id.equals(link.id)))
              .write(SaleItemBatchesCompanion(quantity: Value(r.roundQuantity(link.quantity - restoreQty))));
        }

        if (!isDamaged) {
          final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
          await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
            ProductsCompanion(stockQuantity: Value(r.roundQuantity(product.stockQuantity + line.quantity))),
          );
        }

        await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
              productId: item.productId,
              direction: isDamaged ? 'out' : 'in',
              type: isDamaged ? 'damaged_writeoff' : 'return',
              quantity: line.quantity,
              note: Value(isDamaged
                  ? 'Returned as damaged — written off, not returned to sellable stock'
                  : 'Returned ${line.quantity} units'),
            ));

        final refundAmount = r.roundMoney(line.quantity * item.unitPrice);
        totalRefunded += refundAmount;

        await (db.update(db.saleItems)..where((si) => si.id.equals(line.saleItemId))).write(
          SaleItemsCompanion(quantity: Value(r.roundQuantity(item.quantity - line.quantity))),
        );
      }

      // Recompute the sale's totals from its (now-reduced) items.
      final remainingItems = await (db.select(db.saleItems)..where((si) => si.saleId.equals(saleId))).get();
      final newTotal = r.roundMoney(remainingItems.fold<double>(0, (sum, i) => sum + i.quantity * i.unitPrice));
      final newProfit = r.roundMoney(remainingItems.fold<double>(0, (sum, i) => sum + i.quantity * (i.unitPrice - i.unitCost)));

      final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
      double cashRefund = 0;
      double newAmountPaid = sale.amountPaid;
      if (sale.amountPaid > newTotal) {
        cashRefund = r.roundMoney(sale.amountPaid - newTotal);
        newAmountPaid = newTotal;
      }

      await (db.update(db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          totalAmount: Value(newTotal),
          totalProfit: Value(newProfit),
          amountPaid: Value(newAmountPaid),
        ),
      );

      final returnId = await db.into(db.returns).insert(ReturnsCompanion.insert(
            saleId: saleId,
            reason: reason,
            note: Value(note),
            totalRefunded: totalRefunded,
          ));

      for (final line in lines) {
        final item = await (db.select(db.saleItems)..where((si) => si.id.equals(line.saleItemId))).getSingle();
        await db.into(db.returnItems).insert(ReturnItemsCompanion.insert(
              returnId: returnId,
              saleItemId: line.saleItemId,
              quantity: line.quantity,
              refundAmount: r.roundMoney(line.quantity * item.unitPrice),
            ));
      }

      await _activityLog.log('return', 'created', amount: r.roundMoney(totalRefunded), refId: saleId);

      return ReturnResult(returnId: returnId, totalRefunded: r.roundMoney(totalRefunded), cashRefund: cashRefund);
    });
  }
}
