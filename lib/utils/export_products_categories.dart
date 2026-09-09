import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database/database.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/category_repository.dart';

enum ExportFormat { excel, csv }

/// Exports all ACTIVE categories and products to one file in the chosen
/// format, saved under `Documents/Nova Pro Data/Exports/` (same base data
/// location the app's other exports/backups already use). Returns the
/// created file's path.
Future<String> exportProductsAndCategories(
  AppDatabase db,
  ExportFormat format,
) async {
  final productRepo = ProductRepository(db);
  final categoryRepo = CategoryRepository(db);
  final products = await productRepo.getAllActive();
  final categoriesWithCounts = await categoryRepo.getAllWithCounts();
  final categoryNameById = {
    for (final c in categoriesWithCounts) c.category.id: c.category.name,
  };

  final docs = await getApplicationDocumentsDirectory();
  final exportsDir = Directory(p.join(docs.path, 'Nova Pro Data', 'Exports'));
  if (!await exportsDir.exists()) {
    await exportsDir.create(recursive: true);
  }

  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .split('.')
      .first;

  const productColumns = [
    'Name',
    'Code',
    'Barcode',
    'Category',
    'Unit Type',
    'Size',
    'Selling Price',
    'Current Stock',
    'Min Stock',
  ];

  List<Object?> productRow(Product product) => [
    product.name,
    product.code,
    product.barcode ?? '',
    product.categoryId != null
        ? (categoryNameById[product.categoryId] ?? '')
        : '',
    product.unitType,
    product.variantSize ?? '',
    product.sellingPrice ?? 0,
    product.stockQuantity,
    product.minStock,
  ];

  if (format == ExportFormat.excel) {
    final workbook = xls.Excel.createExcel();

    final categoriesSheet = workbook['Categories'];
    categoriesSheet.appendRow([
      xls.TextCellValue('Name'),
      xls.TextCellValue('Product Count'),
    ]);
    for (final c in categoriesWithCounts) {
      categoriesSheet.appendRow([
        xls.TextCellValue(c.category.name),
        xls.IntCellValue(c.productCount),
      ]);
    }

    final productsSheet = workbook['Products'];
    productsSheet.appendRow(
      productColumns.map((c) => xls.TextCellValue(c)).toList(),
    );
    for (final product in products) {
      productsSheet.appendRow(
        productRow(product)
            .map(
              (v) => switch (v) {
                String s => xls.TextCellValue(s),
                int i => xls.IntCellValue(i),
                double d => xls.DoubleCellValue(d),
                _ => xls.TextCellValue(v.toString()),
              },
            )
            .toList(),
      );
    }

    // Excel.createExcel() starts with a default empty sheet — drop it now
    // that the two real sheets exist, so the workbook opens straight to them.
    if (workbook.sheets.containsKey('Sheet1')) {
      workbook.delete('Sheet1');
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw Exception('Failed to encode the Excel workbook');
    }
    final path = p.join(exportsDir.path, 'products_categories_$timestamp.xlsx');
    await File(path).writeAsBytes(bytes);
    return path;
  } else {
    final buffer = StringBuffer();
    buffer.writeln(productColumns.map(_csvField).join(','));
    for (final product in products) {
      buffer.writeln(productRow(product).map(_csvField).join(','));
    }
    final path = p.join(exportsDir.path, 'products_categories_$timestamp.csv');
    await File(path).writeAsString(buffer.toString());
    return path;
  }
}

/// Quotes a CSV field only when it needs it (contains a comma, quote, or
/// newline), doubling any embedded quotes — standard CSV escaping.
String _csvField(Object? value) {
  final text = value?.toString() ?? '';
  if (text.contains(',') || text.contains('"') || text.contains('\n')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
