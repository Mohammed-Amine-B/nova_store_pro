import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';
import '../../utils/product_images.dart';
import '../../widgets/crop_image_dialog.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductRepository repo;
  final List<Category> categories;
  final Product? editing;

  const ProductFormDialog({
    super.key,
    required this.repo,
    required this.categories,
    this.editing,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final _nameController = TextEditingController(
    text: widget.editing?.name ?? '',
  );
  late final _codeController = TextEditingController(
    text: widget.editing?.code ?? '',
  );
  late final _barcodeController = TextEditingController(
    text: widget.editing?.barcode ?? '',
  );
  late final _minStockController = TextEditingController(
    text: plainNumber(widget.editing?.minStock ?? 5),
  );
  late final _sellingPriceController = TextEditingController(
    text: widget.editing?.sellingPrice != null ? plainNumber(widget.editing!.sellingPrice!) : '',
  );
  late final _variantSizeController = TextEditingController(
    text: widget.editing?.variantSize ?? '',
  );
  final _nameFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _barcodeFocus = FocusNode();
  final _minStockFocus = FocusNode();
  final _variantSizeFocus = FocusNode();

  int? _categoryId;
  bool _codeManuallyEdited = false;
  String _unitType = 'piece';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.editing?.categoryId;
    _codeManuallyEdited = widget.editing != null;
    _unitType = widget.editing?.unitType ?? 'piece';
    _imagePath = widget.editing?.imagePath;
  }

  Future<void> _pickImage() async {
    final picked = await FilePicker.pickFile(type: FileType.image);
    final pickedPath = picked?.path;
    if (pickedPath == null) return;
    final bytes = await File(pickedPath).readAsBytes();
    if (!mounted) return;
    final cropped = await showCropImageDialog(context, bytes);
    if (cropped == null) return;
    final filename = await saveProductImageBytes(cropped);
    if (mounted) setState(() => _imagePath = filename);
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _codeFocus.dispose();
    _barcodeFocus.dispose();
    _minStockFocus.dispose();
    _variantSizeFocus.dispose();
    _variantSizeController.dispose();
    super.dispose();
  }

  Future<void> _onNameChanged(String name) async {
    if (_codeManuallyEdited || name.trim().isEmpty) return;
    final suggested = await widget.repo.suggestCode(name);
    if (mounted && !_codeManuallyEdited) {
      _codeController.text = suggested;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty)
      return;
    final minStock = double.tryParse(_minStockController.text) ?? 0;
    if (widget.editing == null) {
      await widget.repo.add(
        name: _nameController.text,
        code: _codeController.text,
        categoryId: _categoryId,
        barcode: _barcodeController.text.isEmpty
            ? null
            : _barcodeController.text,
        minStock: minStock,
        unitType: _unitType,
        imagePath: _imagePath,
        variantSize: _variantSizeController.text,
      );
    } else {
      await widget.repo.update(
        id: widget.editing!.id,
        name: _nameController.text,
        code: _codeController.text,
        categoryId: _categoryId,
        barcode: _barcodeController.text.isEmpty
            ? null
            : _barcodeController.text,
        minStock: minStock,
        unitType: _unitType,
        sellingPrice: double.tryParse(_sellingPriceController.text),
        imagePath: _imagePath,
        variantSize: _variantSizeController.text,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.editing == null ? l10n.addProduct : l10n.editProduct,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: FutureBuilder<String?>(
                    future: resolveProductImagePath(_imagePath),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                      }
                      return Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.productNameLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onNameChanged,
              onSubmitted: (_) => _codeFocus.requestFocus(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocus,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.productCodeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _codeManuallyEdited = true,
                    onSubmitted: (_) => _barcodeFocus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocus,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.barcodeOptionalLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _minStockFocus.requestFocus(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int?>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.categoryOptionalLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.noneOption)),
                ...widget.categories.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
              initialValue: _unitType,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.unitTypeLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'piece', child: Text(l10n.unitTypePiece)),
                DropdownMenuItem(value: 'kg', child: Text(l10n.unitTypeKg)),
                DropdownMenuItem(value: 'meter', child: Text(l10n.unitTypeMeter)),
              ],
              onChanged: (v) => setState(() => _unitType = v ?? 'piece'),
            ),
            if (widget.editing != null) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: l10n.sellingPriceFieldLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _minStockController,
              focusNode: _minStockFocus,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.lowStockThresholdLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: _unitType == 'piece'
                  ? TextInputType.number
                  : const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _variantSizeFocus.requestFocus(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _variantSizeController,
              focusNode: _variantSizeFocus,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.variantSizeLabel,
                hintText: l10n.variantSizeHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}