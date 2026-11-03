class AppConstants {
  // ─── Categories ───────────────────────────────────────────────────────────
  static const List<Map<String, String>> categories = [
    {'emoji': '🥬', 'label': 'Veggies'},
    {'emoji': '🍎', 'label': 'Fruits'},
    {'emoji': '🥛', 'label': 'Dairy'},
    {'emoji': '🥩', 'label': 'Meat'},
    {'emoji': '🍿', 'label': 'Snacks'},
    {'emoji': '🥤', 'label': 'Drinks'},
    {'emoji': '🧴', 'label': 'Care'},
    {'emoji': '🧹', 'label': 'Cleaning'},
    {'emoji': '📦', 'label': 'Other'},
  ];

  // ─── Units ────────────────────────────────────────────────────────────────
  static const List<String> units = [
    'kg',
    'g',
    'L',
    'ml',
    'pcs',
    'pack',
    'dozen',
    'bottle',
    'can',
    'box',
  ];

  // ─── Stores ───────────────────────────────────────────────────────────────
  static const List<String> stores = [
    'Any',
    'DMart',
    'Zepto',
    'Blinkit',
    'BigBasket',
    'JioMart',
    'Swiggy Instamart',
    'Local Shop',
  ];

  // ─── Priorities ───────────────────────────────────────────────────────────
  static const List<String> priorities = ['High', 'Medium', 'Low'];

  // ─── Repeat options ───────────────────────────────────────────────────────
  static const List<String> repeatOptions = ['Daily', 'Weekly', 'Monthly'];

  // ─── Helper: get emoji for a category label ───────────────────────────────
  static String emojiForCategory(String label) {
    final match = categories.firstWhere(
      (c) => c['label'] == label,
      orElse: () => {'emoji': '📦'},
    );
    return match['emoji']!;
  }
}
