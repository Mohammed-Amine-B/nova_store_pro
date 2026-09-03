import 'package:drift/drift.dart';

// language: 'en' | 'ar' | 'fr'
// themeMode: 'light' | 'dark' | 'system'
class Settings extends Table {
  IntColumn get id => integer()(); // always 1, single row
  TextColumn get shopName => text().withDefault(const Constant('Nova Store'))();
  TextColumn get language => text().withDefault(const Constant('ar'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get appPasswordHash => text().nullable()(); // null = no password set
  TextColumn get securityQuestion => text().nullable()();
  TextColumn get securityAnswerHash => text().nullable()(); // hashed the same way as appPasswordHash
  TextColumn get recoveryCodeHash => text().nullable()(); // hashed the same way as appPasswordHash
  TextColumn get fontSize => text().withDefault(const Constant('medium'))(); // 'small' | 'medium' | 'large'
  TextColumn get backupDestination => text().nullable()(); // a folder path, e.g. "D:\NovaProBackups"
  DateTimeColumn get lastAutoBackupAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}