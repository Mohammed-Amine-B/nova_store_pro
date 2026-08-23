import 'package:drift/drift.dart';
import '../database/database.dart';
import 'activity_log_repository.dart';

class CategoryWithCount {
  final Category category;
  final int productCount;
  CategoryWithCount(this.category, this.productCount);
}

class CategoryRepository {
  final AppDatabase db;
  CategoryRepository(this.db);
  late final ActivityLogRepository _activityLog = ActivityLogRepository(db);

  Future<List<CategoryWithCount>> getAllWithCounts() async {
    final categories = await db.select(db.categories).get();
    final result = <CategoryWithCount>[];
    for (final c in categories) {
      final count = await (db.selectOnly(db.products)
            ..addColumns([db.products.id.count()])
            ..where(db.products.categoryId.equals(c.id) & db.products.isArchived.equals(false)))
          .map((row) => row.read(db.products.id.count()) ?? 0)
          .getSingle();
      result.add(CategoryWithCount(c, count));
    }
    return result;
  }

  /// Throws if a category with this name already exists (case-insensitive).
  Future<void> add(String name) async {
    final existing = await (db.select(db.categories)
          ..where((c) => c.name.lower().equals(name.trim().toLowerCase())))
        .getSingleOrNull();
    if (existing != null) {
      throw Exception('A category named "$name" already exists');
    }
    await db.into(db.categories).insert(CategoriesCompanion.insert(name: name.trim()));
    await _activityLog.log('category', 'created', entityName: name.trim());
  }

  Future<void> update(int id, String name) async {
    final existing = await (db.select(db.categories)
          ..where((c) => c.name.lower().equals(name.trim().toLowerCase()) & c.id.equals(id).not()))
        .getSingleOrNull();
    if (existing != null) {
      throw Exception('A category named "$name" already exists');
    }
    await (db.update(db.categories)..where((c) => c.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name.trim())));
    await _activityLog.log('category', 'updated', entityName: name.trim());
  }

  /// Throws if the category still has products assigned to it.
  Future<void> delete(int id) async {
    final productCount = await (db.selectOnly(db.products)
          ..addColumns([db.products.id.count()])
          ..where(db.products.categoryId.equals(id) & db.products.isArchived.equals(false)))
        .map((row) => row.read(db.products.id.count()) ?? 0)
        .getSingle();

    if (productCount > 0) {
      throw Exception('Cannot delete — $productCount product(s) still use this category');
    }

    final category = await (db.select(db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
    await _activityLog.log('category', 'deleted', entityName: category?.name, refId: id);
  }
}