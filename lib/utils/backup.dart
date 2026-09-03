import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database/database.dart';
import '../data/repositories/settings_repository.dart';

// Restore is a manual process for now: close the app, extract the zip, and
// replace the files under Documents/Nova Pro Data/ yourself. A proper
// "Restore from Backup" button needs its own careful design around the
// open database connection (file locks) and isn't built in this pass.

/// Creates a zip file containing the SQLite database (`nova_store_db.sqlite`)
/// and the `product_images` folder, both living under
/// `Documents/Nova Pro Data/`. Returns the path to the created zip file.
///
/// By default the zip is written to `Documents/Nova Pro Data/Backups/`. Pass
/// [destinationOverride] to write it into a different folder instead (used
/// by the automatic daily backup) — the app's primary data location is
/// never affected either way, this only changes where the zip COPY lands.
Future<String> createBackup({String? destinationOverride}) async {
  final docs = await getApplicationDocumentsDirectory();
  final dataDir = Directory(p.join(docs.path, 'Nova Pro Data'));

  final dbFile = File(p.join(dataDir.path, 'nova_store_db.sqlite'));
  final imagesDir = Directory(p.join(dataDir.path, 'product_images'));

  final backupsDir = destinationOverride != null
      ? Directory(destinationOverride)
      : Directory(p.join(dataDir.path, 'Backups'));
  if (!await backupsDir.exists()) {
    await backupsDir.create(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
  final zipPath = p.join(backupsDir.path, 'nova_pro_backup_$timestamp.zip');

  final encoder = ZipFileEncoder();
  encoder.create(zipPath);

  if (await dbFile.exists()) {
    await encoder.addFile(dbFile, 'nova_store_db.sqlite');
  }
  if (await imagesDir.exists()) {
    await encoder.addDirectory(imagesDir, includeDirName: true);
  }

  await encoder.close();

  return zipPath;
}

/// Checks whether an automatic backup is due (if a destination is configured
/// and it's been 1+ day since the last one — or no backup has ever run),
/// and if so, performs it silently to the configured destination. Safe to
/// call on every app startup — it's a no-op if no destination is set or
/// a backup isn't due yet. Returns the new backup's path if one was made, else null.
Future<String?> runAutoBackupIfDue(AppDatabase db, SettingsRepository settingsRepo) async {
  try {
    final settings = await settingsRepo.getSettings();
    final destination = settings.backupDestination;
    if (destination == null || destination.isEmpty) return null;
    if (!await Directory(destination).exists()) return null; // destination unavailable — skip silently, try again next launch

    final last = settings.lastAutoBackupAt;
    final due = last == null || DateTime.now().difference(last).inDays >= 1;
    if (!due) return null;

    final path = await createBackup(destinationOverride: destination);
    await settingsRepo.updateLastAutoBackupAt(DateTime.now());
    return path;
  } catch (_) {
    // Silent by design — auto-backup must never interrupt or crash startup.
    // It simply retries on the next launch.
    return null;
  }
}
