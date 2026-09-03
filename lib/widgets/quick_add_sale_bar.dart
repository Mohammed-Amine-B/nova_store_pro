import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import '../data/database/database.dart';
import '../data/repositories/sales_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/formatting.dart';
import 'product_thumbnail.dart';
import 'money_text.dart';

class QuickAddSaleBar extends StatefulWidget {
  final AppDatabase db;
  final DateTime date;
  final VoidCallback onAdded;
  final FocusNode? focusNode;
  final String label;
  final bool minimalHeader;

  const QuickAddSaleBar({
    super.key,
    required this.db,
    required this.date,
    required this.onAdded,
    this.focusNode,
    this.label = 'Quick Add Product',
    this.minimalHeader = false,
  });

  @override
  State<QuickAddSaleBar> createState() => _QuickAddSaleBarState();
}

class _QuickAddSaleBarState extends State<QuickAddSaleBar> {
  late final SalesRepository _repo = SalesRepository(widget.db);
  final _searchController = TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<Product> _matches = [];

  void _showOverlay() {
    _removeOverlay();
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final width = renderBox.size.width;
    final height = renderBox.size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, height + 6),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _matches.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                itemBuilder: (context, i) {
                  final l10n = AppLocalizations.of(context)!;
                  final p = _matches[i];
                  final outOfStock = p.stockQuantity <= 0;
                  final stockColor = outOfStock
                      ? Theme.of(context).colorScheme.error
                      : const Color(0xFF16A34A);
                  return InkWell(
                    onTap: () => _pick(p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ProductThumbnail(imagePath: p.imagePath, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: stockColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        productDisplayName(p),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.barcode ?? p.code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MoneyText(
                                p.sellingPrice != null
                                    ? formatMoney(p.sellingPrice!)
                                    : '—',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0E7C7B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.inStockCount(
                                  formatQuantity(p.stockQuantity, p.unitType),
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: stockColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _onSearchChanged(String query) async {
    final matches = await _repo.searchProducts(query);
    if (!mounted) return;
    setState(() => _matches = matches);
    if (matches.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  Future<void> _pick(Product p) async {
    _removeOverlay();
    setState(() {
      _searchController.clear();
      _matches = [];
    });

    final isPiece = p.unitType == 'piece';
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: plainNumber(p.sellingPrice ?? 0),
    );
    String? error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                    Icons.point_of_sale_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  productDisplayName(p),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: p.stockQuantity <= 0
                              ? Theme.of(context).colorScheme.error
                              : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.inStockCount(
                            formatQuantity(p.stockQuantity, p.unitType),
                          ),
                          style: TextStyle(
                            color: p.stockQuantity <= 0
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (error != null) ...[
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              labelText: l10n.quantityLabel,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: isPiece
                                ? TextInputType.number
                                : const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: l10n.sellingPriceFieldLabel,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  var quantity = double.tryParse(quantityController.text) ?? 0;
                  if (isPiece) quantity = quantity.roundToDouble();
                  final price = double.tryParse(priceController.text) ?? 0;
                  if (quantity <= 0 || price <= 0) {
                    setDialogState(() => error = l10n.enterValidQuantityPrice);
                    return;
                  }
                  try {
                    await _repo.createSale(
                      date: widget.date,
                      lines: [
                        SaleLineInput(
                          productId: p.id,
                          quantity: quantity,
                          unitPrice: price,
                        ),
                      ],
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    setDialogState(() => error = e.toString());
                  }
                },
                child: Text(l10n.addSaleAction),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) widget.onAdded();
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final field = Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _overlayEntry != null) {
          _removeOverlay();
          setState(() => _matches = []);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          key: _fieldKey,
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: l10n.searchToSellHint,
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(
                    l10n.ctrlFHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );

    if (widget.minimalHeader) return field;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }
}
