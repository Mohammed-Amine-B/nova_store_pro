import 'package:drift/drift.dart';
import '../database/database.dart';

class NoteRepository {
  final AppDatabase db;
  NoteRepository(this.db);

  Future<int> add({
    required String title,
    String? content,
    String type = 'general',
    double? price,
    double? quantity,
  }) async {
    return db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(
            title: title.trim(),
            content: Value(content?.trim()),
            type: Value(type),
            price: Value(price),
            quantity: Value(quantity),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String title,
    String? content,
    String type = 'general',
    double? price,
    double? quantity,
  }) async {
    await (db.update(db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        title: Value(title.trim()),
        content: Value(content?.trim()),
        type: Value(type),
        price: Value(price),
        quantity: Value(quantity),
      ),
    );
  }

  Future<void> markDone(int id, bool isDone) async {
    await (db.update(db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(isDone: Value(isDone)),
    );
  }

  Future<void> delete(int id) async {
    await (db.delete(db.notes)..where((n) => n.id.equals(id))).go();
  }

  /// Open (not done) notes first (newest first), then done ones after (newest first).
  /// Pass [type] to only return notes of that type.
  Future<List<Note>> getAll({String? type}) async {
    final query = db.select(db.notes)
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);
    if (type != null) {
      query.where((n) => n.type.equals(type));
    }
    final all = await query.get();
    final open = all.where((n) => !n.isDone).toList();
    final done = all.where((n) => n.isDone).toList();
    return [...open, ...done];
  }

  Future<int> getOpenCount() async {
    final open = await (db.select(
      db.notes,
    )..where((n) => n.isDone.equals(false))).get();
    return open.length;
  }
}
