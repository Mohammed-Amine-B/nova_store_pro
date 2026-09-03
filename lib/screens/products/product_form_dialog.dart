import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/database/database.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/formatting.dart';
import '../../utils/product_images.dart';
import '../../widgets/crop_image_dialog.dart';
import '../../widgets/enter_to_submit.dart';

/// Controllers for one size-variant row in the "Product with Sizes" flow.
/// Not a widget — just the per-row form state, so rows can be added/removed
/// freely without losing what's already typed in the others.
class _SizeRowControllers {
  final variantSize = TextEditingController();
  final code = TextEditingController();
  final barcode = TextEditingController();
  final minStock = TextEditingController(text: '5');

  void dispose() {
    variantSize.dispose();
    code.dispose();
    barcode.dispose();
    minStock.dispose();
  }
}

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
    text: widget.editing?.sellingPrice != null
        ? plainNumber(widget.editing!.sellingPrice!)
        : '',
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

  // "Product with Sizes" flow — only reachable when adding a brand-new
  // product (widget.editing == null). Editing always uses the normal
  // single-product form above, untouched.
  bool _multiSize = false;
  final List<_SizeRowControllers> _sizeRows = [_SizeRowControllers()];
  bool _saving = false;

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

  /// Opens the shop owner's own browser to a Google Images search for the
  /// current product name — purely a convenience shortcut. The app never
  /// fetches, displays, or picks an image itself; saving/choosing a file
  /// afterward still goes through the existing photo picker.
  Future<void> _searchImagesOnline() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final categoryName = _categoryId != null
        ? widget.categories
              .firstWhere(
                (c) => c.id == _categoryId,
                orElse: () =>
                    Category(id: -1, name: '', createdAt: DateTime.now()),
              )
              .name
        : null;
    final query = (categoryName != null && categoryName.isNotEmpty)
        ? '$name $categoryName'
        : name;
    final url = Uri.parse(
      'https://www.google.com/search?tbm=isch&q=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _codeFocus.dispose();
    _barcodeFocus.dispose();
    _minStockFocus.dispose();
    _variantSizeFocus.dispose();
    _variantSizeController.dispose();
    for (final row in _sizeRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _onNameChanged(String name) async {
    if (_codeManuallyEdited || name.trim().isEmpty) return;
    final suggested = await widget.repo.suggestCode(name);
    if (mounted && !_codeManuallyEdited) {
      _codeController.text = suggested;
    }
  }

  void _addSizeRow() => setState(() => _sizeRows.add(_SizeRowControllers()));

  void _removeSizeRow(int index) {
    if (_sizeRows.length <= 1) return;
    setState(() {
      _sizeRows.removeAt(index).dispose();
    });
  }

  bool get _multiSizeValid =>
      _nameController.text.trim().isNotEmpty &&
      _sizeRows.every(
        (r) =>
            r.variantSize.text.trim().isNotEmpty &&
            r.code.text.trim().isNotEmpty,
      );

  Future<void> _save() async {
    if (widget.editing == null && _multiSize) {
      if (!_multiSizeValid) return;
      setState(() => _saving = true);
      for (final row in _sizeRows) {
        final minStock = double.tryParse(row.minStock.text) ?? 0;
        await widget.repo.add(
          name: _nameController.text,
          code: row.code.text,
          categoryId: _categoryId,
          barcode: row.barcode.text.isEmpty ? null : row.barcode.text,
          minStock: minStock,
          unitType: _unitType,
          variantSize: row.variantSize.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty) {
      return;
    }
    final minStock = double.tryParse(_minStockController.text) ?? 0;
    setState(() => _saving = true);
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
    final isAdding = widget.editing == null;
    final saveEnabled =
        !_saving && (!(isAdding && _multiSize) || _multiSizeValid);

    return EnterToSubmit(
      onSubmit: saveEnabled ? _save : null,
      child: AlertDialog(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdding) ...[
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.normalProductOption),
                        icon: const Icon(Icons.inventory_2_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.productWithSizesOption),
                        icon: const Icon(Icons.straighten),
                      ),
                    ],
                    selected: {_multiSize},
                    onSelectionChanged: (s) =>
                        setState(() => _multiSize = s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(
                        0xFF0E7C7B,
                      ).withValues(alpha: 0.15),
                      selectedForegroundColor: const Color(0xFF0E7C7B),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (isAdding && _multiSize)
                  _buildMultiSizeForm(context, l10n)
                else
                  _buildNormalForm(context, l10n),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: saveEnabled ? _save : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0E7C7B),
            ),
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalForm(BuildContext context, AppLocalizations l10n) {
    return Column(
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameController,
            builder: (context, value, _) {
              final hasName = value.text.trim().isNotEmpty;
              return Tooltip(
                message: hasName ? '' : l10n.searchImagesOnlineDisabledHint,
                child: TextButton.icon(
                  onPressed: hasName ? _searchImagesOnline : null,
                  icon: const Icon(Icons.image_search, size: 18),
                  label: Text(l10n.searchImagesOnlineAction),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0E7C7B),
                    disabledForegroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            l10n.searchImagesOnlineHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
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
    );
  }

  Widget _buildMultiSizeForm(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.productNameLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() {}),
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
        const SizedBox(height: 20),
        Divider(color: theme.dividerColor),
        const SizedBox(height: 8),
        Text(
          l10n.sizesSectionLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0E7C7B),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _sizeRows.length; i++) ...[
          _buildSizeRow(context, l10n, i),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _addSizeRow,
          icon: const Icon(Icons.add, color: Color(0xFF0E7C7B)),
          label: Text(
            l10n.addAnotherSizeAction,
            style: const TextStyle(color: Color(0xFF0E7C7B)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF0E7C7B)),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeRow(BuildContext context, AppLocalizations l10n, int index) {
    final row = _sizeRows[index];
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.sizeLabelFieldLabel} #${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (_sizeRows.length > 1)
                IconButton(
                  onPressed: () => _removeSizeRow(index),
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: l10n.removeSizeTooltip,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.variantSize,
                  decoration: InputDecoration(
                    labelText: l10n.sizeLabelFieldLabel,
                    hintText: l10n.variantSizeHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: row.code,
                  decoration: InputDecoration(
                    labelText: l10n.productCodeLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.barcode,
                  decoration: InputDecoration(
                    labelText: l10n.barcodeOptionalLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: row.minStock,
                  decoration: InputDecoration(
                    labelText: l10n.lowStockThresholdLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: _unitType == 'piece'
                      ? TextInputType.number
                      : const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
