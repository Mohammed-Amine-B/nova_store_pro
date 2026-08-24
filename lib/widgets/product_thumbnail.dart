import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/product_images.dart';

/// A small rounded-square product photo thumbnail for search/picker list
/// items, falling back to a neutral placeholder when the product has no
/// photo. (The main product table in products_screen.dart uses its own
/// circular-avatar-with-initial treatment — this is the picker-list variant.)
class ProductThumbnail extends StatelessWidget {
  final String? imagePath;
  final double size;
  const ProductThumbnail({super.key, required this.imagePath, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String?>(
      future: resolveProductImagePath(imagePath),
      builder: (context, snapshot) {
        final resolved = snapshot.data;
        return Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: resolved != null
              ? Image.file(File(resolved), fit: BoxFit.cover)
              : Icon(
                  Icons.image_outlined,
                  size: size * 0.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
        );
      },
    );
  }
}
