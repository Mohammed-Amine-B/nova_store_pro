import 'package:drift/drift.dart';
import '../database/database.dart';

class ActivityLogRepository {
  final AppDatabase db;
  ActivityLogRepository(this.db);

  Future<void> log(
    String category,
    String action, {
    double? amount,
    String? entityName,
    int? refId,
  }) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
          category: category,
          action: action,
          amount: Value(amount),
          entityLabel: Value(entityName),
          refId: Value(refId),
        ));
  }

  /// Newest first, optionally filtered by category and/or a date range.
  Future<List<ActivityLogData>> getEntries({
    String? category,
    DateTime? start,
    DateTime? end,
  }) async {
    final query = db.select(db.activityLog)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (category != null) query.where((t) => t.category.equals(category));
    if (start != null) query.where((t) => t.createdAt.isBiggerOrEqualValue(start));
    if (end != null) query.where((t) => t.createdAt.isSmallerThanValue(end));
    return query.get();
  }
}
