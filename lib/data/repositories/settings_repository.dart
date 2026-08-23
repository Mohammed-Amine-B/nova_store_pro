import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class SettingsRepository {
  final AppDatabase db;
  SettingsRepository(this.db);

  /// Returns the single settings row, creating it with defaults if it doesn't exist yet.
  Future<Setting> getSettings() async {
    final existing = await (db.select(db.settings)..where((s) => s.id.equals(1))).getSingleOrNull();
    if (existing != null) return existing;

    await db.into(db.settings).insert(
          SettingsCompanion.insert(id: const Value(1)),
        );
    return (db.select(db.settings)..where((s) => s.id.equals(1))).getSingle();
  }

  Future<void> updateShopName(String name) async {
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(shopName: Value(name.trim())));
  }

  Future<void> updateThemeMode(String mode) async {
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(themeMode: Value(mode)));
  }

  Future<void> updateLanguage(String code) async {
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(language: Value(code)));
  }

  String _hash(String password) => sha256.convert(utf8.encode(password)).toString();

  Future<bool> hasPassword() async {
    final settings = await getSettings();
    return settings.appPasswordHash != null && settings.appPasswordHash!.isNotEmpty;
  }

  Future<bool> verifyPassword(String password) async {
    final settings = await getSettings();
    if (settings.appPasswordHash == null) return true; // no password set = always "correct"
    return settings.appPasswordHash == _hash(password);
  }

  /// Sets a new password. If one already exists, [currentPassword] must match it first.
  Future<bool> setPassword(String newPassword, {String? currentPassword}) async {
    final settings = await getSettings();
    if (settings.appPasswordHash != null) {
      if (currentPassword == null || _hash(currentPassword) != settings.appPasswordHash) {
        return false;
      }
    }
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(appPasswordHash: Value(_hash(newPassword))));
    return true;
  }

  /// Removes the password. Requires the current password to confirm.
  Future<bool> removePassword(String currentPassword) async {
    final settings = await getSettings();
    if (settings.appPasswordHash == null) return true;
    if (_hash(currentPassword) != settings.appPasswordHash) return false;
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(const SettingsCompanion(appPasswordHash: Value(null)));
    return true;
  }
}