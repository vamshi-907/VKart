import 'package:flutter/material.dart';

/// Picks a representative icon for a Firestore category name.
///
/// Categories are fully dynamic (derived from the products collection), so
/// icons are matched by keyword with a generic fallback for anything new the
/// store adds later — no screen depends on a hardcoded category list.
IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('rice') || c.contains('pulse') || c.contains('dal')) {
    return Icons.rice_bowl;
  }
  if (c.contains('oil')) return Icons.local_drink;
  if (c.contains('tea') || c.contains('coffee')) return Icons.coffee;
  if (c.contains('soap') || c.contains('detergent') || c.contains('wash')) {
    return Icons.soap;
  }
  if (c.contains('shampoo') || c.contains('hair')) return Icons.spa;
  if (c.contains('tooth') || c.contains('paste')) return Icons.brush;
  if (c.contains('snack') || c.contains('biscuit')) return Icons.fastfood;
  if (c.contains('dairy') || c.contains('milk')) return Icons.icecream;
  if (c.contains('drink') || c.contains('juice')) return Icons.water_drop;
  if (c.contains('agarbath') || c.contains('pooja')) {
    return Icons.local_fire_department;
  }
  return Icons.category;
}
