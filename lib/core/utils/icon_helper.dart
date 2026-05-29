import 'package:flutter/material.dart';

class IconHelper {
  /// Maps a category name to a clean, relevant Material icon.
  /// This avoids using emojis in the UI as per the user guidelines.
  static IconData getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('kopi') && !name.contains('non')) {
      return Icons.coffee_rounded;
    } else if (name.contains('non-kopi') || name.contains('drink') || name.contains('minuman')) {
      return Icons.local_drink_rounded;
    } else if (name.contains('makanan') || name.contains('food')) {
      return Icons.restaurant_rounded;
    } else if (name.contains('snack') || name.contains('cemilan')) {
      return Icons.cookie_rounded;
    } else if (name.contains('dessert') || name.contains('cake') || name.contains('manis')) {
      return Icons.cake_rounded;
    } else if (name.contains('semua')) {
      return Icons.grid_view_rounded;
    }
    return Icons.restaurant_menu_rounded;
  }

  /// Gets a placeholder icon for products based on category name or product name
  static IconData getProductPlaceholderIcon(String productName, String? categoryName) {
    final pName = productName.toLowerCase();
    final cName = (categoryName ?? '').toLowerCase();

    if (pName.contains('espresso') || pName.contains('americano') || pName.contains('cappuccino') || pName.contains('latte') || pName.contains('white') || pName.contains('brew') || cName.contains('kopi')) {
      if (cName.contains('non-kopi')) return Icons.local_drink_rounded;
      return Icons.coffee_rounded;
    }
    if (pName.contains('tea') || pName.contains('chocolate') || pName.contains('taro') || pName.contains('matcha')) {
      return Icons.local_drink_rounded;
    }
    if (pName.contains('sandwich') || pName.contains('toast') || pName.contains('croissant') || pName.contains('bread')) {
      return Icons.bakery_dining_rounded;
    }
    if (pName.contains('cookie') || pName.contains('brownie')) {
      return Icons.cookie_rounded;
    }
    if (pName.contains('cake') || pName.contains('cotta') || pName.contains('tiramisu')) {
      return Icons.cake_rounded;
    }
    return Icons.restaurant_rounded;
  }
}
