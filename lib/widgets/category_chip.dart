import 'package:flutter/material.dart';

/// A small set of palette colors, picked deterministically per category name
/// so the same category always gets the same color, and different categories
/// look visually distinct from each other.
const _chipPalette = [
  Color(0xFF0E7C7B), // teal
  Color(0xFFF2A93B), // saffron
  Color(0xFFE4572E), // terracotta
  Color(0xFF6D598A), // plum
  Color(0xFF2E7D32), // olive green
  Color(0xFF2469A6), // denim
];

Color colorForCategory(String name) {
  final hash = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
  return _chipPalette[hash % _chipPalette.length];
}

class CategoryChip extends StatelessWidget {
  final String name;
  const CategoryChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    if (name == '—') {
      return Text('—', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)));
    }
    final color = colorForCategory(name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}