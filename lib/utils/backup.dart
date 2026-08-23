import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Restore is a manual process for now: close the app, extract the zip, and
// replace the files under Documents/Nova Pro Data/ yourself. A proper
// "Restore from Backup" button needs its own careful design around the
// open database connection (file locks) and isn't built in this pass.

/// Creates a zip file containing the SQLite database (`nova_store_db.sqlite`)
/// and the `product_images` folder, both living under
/// `Documents/Nova Pro Data/`. Returns the path to the created zip file.
Future<String> createBackup() async {
  final docs = await getApplicationDocumentsDirectory();
  final dataDir = Directory(p.join(docs.path, 'Nova Pro Data'));

  final dbFile = File(p.join(dataDir.path, 'nova_store_db.sqlite'));
  final imagesDir = Directory(p.join(dataDir.path, 'product_images'));

  final backupsDir = Directory(p.join(dataDir.path, 'Backups'));
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
