import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class SetPasswordResult {
  final bool success;
  final String? recoveryCode; // only non-null the first time a password is set — must be shown to the user ONCE
  SetPasswordResult({required this.success, this.recoveryCode});
}

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

  Future<void> updateFontSize(String size) async {
    await (db.update(db.settings)..where((s) => s.id.equals(1)))
        .write(SettingsCompanion(fontSize: Value(size)));
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  /// A 10-character alphanumeric code, excluding visually-ambiguous characters
  /// (0/O, 1/I/L), so it's easy for a shop owner to write down and re-type.
  String _generateRecoveryCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<bool> hasPassword() async {
    final settings = await getSettings();
    return settings.appPasswordHash != null && settings.appPasswordHash!.isNotEmpty;
  }

  Future<bool> verifyPassword(String password) async {
    final settings = await getSettings();
    if (settings.appPasswordHash == null) return true; // no password set = always "correct"
    return settings.appPasswordHash == _hash(password);
  }

  /// Whether a security question and/or recovery code was ever set up — used to
  /// decide whether the "forgot password" flow can offer anything at all.
  Future<bool> hasRecoveryOptions() async {
    final settings = await getSettings();
    return settings.securityQuestion != null || settings.recoveryCodeHash != null;
  }

  /// Sets a new password. If one already exists, [currentPassword] must match it first.
  /// If this is the FIRST password ever set, [securityQuestion] and [securityAnswer] are
  /// required — a one-time recovery code is generated and returned in the result (this
  /// is the only time it's ever available in plaintext).
  Future<SetPasswordResult> setPassword(
    String newPassword, {
    String? currentPassword,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    final settings = await getSettings();
    final isFirstPassword = settings.appPasswordHash == null;

    if (!isFirstPassword) {
      if (currentPassword == null || _hash(currentPassword) != settings.appPasswordHash) {
        return SetPasswordResult(success: false);
      }
      await (db.update(db.settings)..where((s) => s.id.equals(1)))
          .write(SettingsCompanion(appPasswordHash: Value(_hash(newPassword))));
      return SetPasswordResult(success: true);
    }

    if (securityQuestion == null ||
        securityQuestion.trim().isEmpty ||
        securityAnswer == null ||
        securityAnswer.trim().isEmpty) {
      return SetPasswordResult(success: false);
    }

    final recoveryCode = _generateRecoveryCode();
    await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(
        appPasswordHash: Value(_hash(newPassword)),
        securityQuestion: Value(securityQuestion.trim()),
        securityAnswerHash: Value(_hash(securityAnswer.trim().toLowerCase())),
        recoveryCodeHash: Value(_hash(recoveryCode)),
      ),
    );
    return SetPasswordResult(success: true, recoveryCode: recoveryCode);
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

  /// Returns the stored security question, or null if none was ever set.
  Future<String?> getSecurityQuestion() async {
    final settings = await getSettings();
    return settings.securityQuestion;
  }

  /// Hashes and compares [answer] against the stored security answer.
  Future<bool> verifySecurityAnswer(String answer) async {
    final settings = await getSettings();
    if (settings.securityAnswerHash == null) return false;
    return settings.securityAnswerHash == _hash(answer.trim().toLowerCase());
  }

  /// Hashes and compares [code] against the stored recovery code.
  Future<bool> verifyRecoveryCode(String code) async {
    final settings = await getSettings();
    if (settings.recoveryCodeHash == null) return false;
    return settings.recoveryCodeHash == _hash(code.trim().toUpperCase());
  }

  /// Resets the password directly, bypassing the normal current-password check — only
  /// call this after [verifySecurityAnswer] or [verifyRecoveryCode] has already succeeded.
  /// Also invalidates the old recovery code by generating and storing a new one, returned
  /// here so it can be shown to the user as their new one-time code going forward.
  Future<String> resetPasswordAfterRecovery(String newPassword) async {
    final newCode = _generateRecoveryCode();
    await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(
        appPasswordHash: Value(_hash(newPassword)),
        recoveryCodeHash: Value(_hash(newCode)),
      ),
    );
    return newCode;
  }
}
