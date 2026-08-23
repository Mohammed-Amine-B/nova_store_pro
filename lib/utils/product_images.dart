import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const int _thumbnailSize = 400;

Future<Directory> _imagesDir() async {
  final dir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(dir.path, 'Nova Pro Data', 'product_images'));
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  return imagesDir;
}

/// Resolves a stored filename to a full path. Returns null if no filename given.
Future<String?> resolveProductImagePath(String? filename) async {
  if (filename == null || filename.isEmpty) return null;
  final dir = await _imagesDir();
  return p.join(dir.path, filename);
}

/// Reads the picked image, resizes it to fit within 400x400 (preserving aspect
/// ratio), re-encodes as JPEG (quality 85), and saves it under a unique filename.
/// Returns the filename to store in the database.
Future<String> saveProductImage(String sourcePath) async {
  final bytes = await File(sourcePath).readAsBytes();
  return saveProductImageBytes(bytes);
}

/// Same pipeline as [saveProductImage] but starting from already-in-memory bytes
/// (e.g. from a crop operation): resize to fit within 400x400, re-encode as
/// JPEG quality 85, save under a unique filename. Returns the filename.
Future<String> saveProductImageBytes(Uint8List bytes) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Could not read the selected image file');
  }
  final resized = img.copyResize(
    decoded,
    width: decoded.width >= decoded.height ? _thumbnailSize : null,
    height: decoded.height > decoded.width ? _thumbnailSize : null,
  );
  final jpg = img.encodeJpg(resized, quality: 85);

  final dir = await _imagesDir();
  final filename = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final destFile = File(p.join(dir.path, filename));
  await destFile.writeAsBytes(jpg);
  return filename;
}

Future<void> deleteProductImage(String? filename) async {
  if (filename == null || filename.isEmpty) return;
  final path = await resolveProductImagePath(filename);
  if (path == null) return;
  final file = File(path);
  if (await file.exists()) await file.delete();
}
