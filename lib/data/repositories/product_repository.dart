import 'package:drift/drift.dart';
import '../database/database.dart';
import 'product_code_generator.dart';
import '../../utils/rounding.dart';
import '../../utils/product_images.dart';
import 'activity_log_repository.dart';

class ProductRepository {
  final AppDatabase db;
  ProductRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  /// Search across name, code, and barcode. Empty query returns all active products.
  Future<List<Product>> search(String query, {int? categoryId}) async {
    final q = query.trim().toLowerCase();
    final stmt = db.select(db.products)
      ..where((p) => p.isArchived.equals(false));
    if (categoryId != null) {
      stmt.where((p) => p.categoryId.equals(categoryId));
    }
    if (q.isNotEmpty) {
      stmt.where((p) =>
          p.name.lower().like('%$q%') |
          p.code.lower().like('%$q%') |
          p.barcode.lower().like('%$q%'));
    }
    return stmt.get();
  }

  /// Generates a unique code from the product name, appending -2, -3, ... on collision.
  Future<String> suggestCode(String name) async {
    final base = generateProductCode(name);
    var candidate = base;
    var suffix = 2;
    while (await _codeExists(candidate)) {
      candidate = '$base-$suffix';
      suffix++;
    }
    return candidate;
  }

  Future<bool> _codeExists(String code) async {
    final existing = await (db.select(db.products)
          ..where((p) => p.code.lower().equals(code.toLowerCase())))
        .getSingleOrNull();
    return existing != null;
  }

  Future<int> add({
    required String name,
    required String code,
    int? categoryId,
    String? barcode,
    required double minStock,
    required String unitType,
    String? imagePath,
    String? variantSize,
  }) async {
    final id = await db.into(db.products).insert(ProductsCompanion.insert(
          name: name.trim(),
          code: code.trim(),
          categoryId: Value(categoryId),
          barcode: Value(barcode?.trim()),
          minStock: Value(minStock),
          unitType: Value(unitType),
          imagePath: Value(imagePath),
          variantSize: Value(variantSize?.trim().isEmpty ?? true ? null : variantSize!.trim()),
        ));
    await _activityLog.log('product', 'created', entityName: name.trim());
    return id;
  }

    Future<void> update({
    required int id,
    required String name,
    required String code,
    int? categoryId,
    String? barcode,
    required double minStock,
    required String unitType,
    double? sellingPrice,
    String? imagePath,
    String? variantSize,
  }) async {
    final existing = await (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
    final oldImagePath = existing?.imagePath;

    await (db.update(db.products)..where((p) => p.id.equals(id))).write(
      ProductsCompanion(
        name: Value(name.trim()),
        code: Value(code.trim()),
        categoryId: Value(categoryId),
        barcode: Value(barcode?.trim()),
        minStock: Value(minStock),
        unitType: Value(unitType),
        sellingPrice: sellingPrice != null ? Value(roundMoney(sellingPrice)) : const Value.absent(),
        imagePath: Value(imagePath),
        variantSize: Value(variantSize?.trim().isEmpty ?? true ? null : variantSize!.trim()),
      ),
    );

    if (imagePath != oldImagePath && oldImagePath != null) {
      await deleteProductImage(oldImagePath);
    }

    await _activityLog.log('product', 'updated', entityName: name.trim());
  }

  /// Updates only the product's photo. Deletes the old image file (if there was
  /// one and it's being replaced or cleared) after the write succeeds.
  Future<void> updateImage(int productId, String? imagePath) async {
    final existing = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingleOrNull();
    final oldImagePath = existing?.imagePath;

    await (db.update(db.products)..where((p) => p.id.equals(productId)))
        .write(ProductsCompanion(imagePath: Value(imagePath)));

    if (imagePath != oldImagePath && oldImagePath != null) {
      await deleteProductImage(oldImagePath);
    }
  }

  /// Permanently deletes a product row. Only allowed if the product has
  /// zero history — never appeared in a sale, a purchase, or a stock movement.
  /// Throws if it has any history, so real business data is never lost.
  Future<void> deletePermanently(int id) async {
    final saleCount = await (db.selectOnly(db.saleItems)
          ..addColumns([db.saleItems.id.count()])
          ..where(db.saleItems.productId.equals(id)))
        .map((row) => row.read(db.saleItems.id.count()) ?? 0)
        .getSingle();
    if (saleCount > 0) {
      throw Exception('Cannot delete — this product has $saleCount sale record(s)');
    }

    final purchaseCount = await (db.selectOnly(db.purchaseItems)
          ..addColumns([db.purchaseItems.id.count()])
          ..where(db.purchaseItems.productId.equals(id)))
        .map((row) => row.read(db.purchaseItems.id.count()) ?? 0)
        .getSingle();
    if (purchaseCount > 0) {
      throw Exception('Cannot delete — this product has $purchaseCount purchase record(s)');
    }

    final movementCount = await (db.selectOnly(db.stockMovements)
          ..addColumns([db.stockMovements.id.count()])
          ..where(db.stockMovements.productId.equals(id)))
        .map((row) => row.read(db.stockMovements.id.count()) ?? 0)
        .getSingle();
    if (movementCount > 0) {
      throw Exception('Cannot delete — this product has $movementCount stock movement(s)');
    }

    final product = await (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();

    // Safe to delete: also clean up any batches (should be empty of history but may still have rows).
    await (db.delete(db.productBatches)..where((b) => b.productId.equals(id))).go();
    await (db.delete(db.products)..where((p) => p.id.equals(id))).go();

    await _activityLog.log('product', 'deleted', entityName: product?.name, refId: id);
  }

  /// Products are archived, never hard-deleted.
  Future<void> archive(int id) async {
    final product = await (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
    await (db.update(db.products)..where((p) => p.id.equals(id)))
        .write(const ProductsCompanion(isArchived: Value(true)));
    await _activityLog.log('product', 'archived', entityName: product?.name, refId: id);
  }

  Future<List<Product>> getAllActive() async {
    return (db.select(db.products)..where((p) => p.isArchived.equals(false))).get();
  }

  Future<double> stockValueAtBuyPrice() async {
    final rows = await (db.selectOnly(db.productBatches)
          ..addColumns([db.productBatches.buyPrice, db.productBatches.quantity]))
        .get();
    var total = 0.0;
    for (final row in rows) {
      final price = row.read(db.productBatches.buyPrice) ?? 0;
      final qty = row.read(db.productBatches.quantity) ?? 0;
      total += price * qty;
    }
    return roundMoney(total);
  }

  Future<Product?> getById(int id) async {
    return (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// All other ACTIVE products sharing the same name (i.e. size/type variants
  /// of the same item, distinguished by variantSize), excluding excludeId.
  Future<List<Product>> getVariants(String name, {required int excludeId}) async {
    return (db.select(db.products)
          ..where((p) =>
              p.name.equals(name) &
              p.isArchived.equals(false) &
              p.id.equals(excludeId).not()))
        .get();
  }

  /// Oldest first — matches FIFO consumption order.
  Future<List<ProductBatche>> getBatches(int productId) async {
    return (db.select(db.productBatches)
          ..where((b) => b.productId.equals(productId))
          ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
        .get();
  }

  /// Most recent first — for the movements log view.
  Future<List<StockMovement>> getMovements(int productId) async {
    return (db.select(db.stockMovements)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  /// Adds stock via FIFO batch rules, updates cached stock, logs the movement,
  /// and always updates the selling price (per Add Stock flow decision).
  Future<void> addStock({
    required int productId,
    required double quantity,
    required double buyPrice,
    required DateTime purchaseDate,
    required double sellingPrice,
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
        // Top up the existing latest batch instead of creating a new one.
        batchId = latestBatch.id;
        await (db.update(db.productBatches)..where((b) => b.id.equals(batchId)))
            .write(ProductBatchesCompanion(
                quantity: Value(roundQuantity(latestBatch.quantity + quantity))));
      } else {
        batchId = await db.into(db.productBatches).insert(ProductBatchesCompanion.insert(
              productId: productId,
              buyPrice: roundMoney(buyPrice),
              quantity: roundQuantity(quantity),
              purchaseDate: purchaseDate,
            ));
      }

      // Update cached stock total.
      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(roundQuantity(product.stockQuantity + quantity))),
      );

      // Build the movement note, flagging a price change if one happened.
      String note = 'Added $quantity units @ $buyPrice DA';
      final priceChanged = product.sellingPrice != sellingPrice;
      if (priceChanged) {
        note += ' — price changed ${product.sellingPrice ?? "unset"} → $sellingPrice DA';
      }

      // Always set the selling price (Add Stock always prompts for it, per decision).
      await (db.update(db.products)..where((p) => p.id.equals(productId)))
          .write(ProductsCompanion(sellingPrice: Value(roundMoney(sellingPrice))));

      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            productId: productId,
            batchId: Value(batchId),
            direction: 'in',
            type: 'stock_add',
            quantity: roundQuantity(quantity),
            note: Value(note),
          ));
    });
  }

  Future<List<Product>> getArchived() async {
    return (db.select(db.products)..where((p) => p.isArchived.equals(true))).get();
  }

  Future<void> unarchive(int id) async {
    final product = await (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
    await (db.update(db.products)..where((p) => p.id.equals(id)))
        .write(const ProductsCompanion(isArchived: Value(false)));
    await _activityLog.log('product', 'restored', entityName: product?.name, refId: id);
  }
}