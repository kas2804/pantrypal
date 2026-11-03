import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pantry_item.dart';

class PantryNotifier extends StateNotifier<List<PantryItem>> {
  Box? _box;

  PantryNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('pantry');
    _load();
  }

  void _load() {
    if (_box == null) return;
    final items = _box!.values.map((v) => PantryItem.fromMap(v as Map)).toList()
      ..sort((a, b) {
        // Out of Stock first, then Running Low, then In Stock
        const order = {'Out of Stock': 0, 'Running Low': 1, 'In Stock': 2};
        return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
      });
    state = items;
  }

  Future<void> addItem(PantryItem item) async {
    await _box?.put(item.id, item.toMap());
    _load();
  }

  Future<void> deleteItem(String id) async {
    await _box?.delete(id);
    _load();
  }

  // Cycles the status of one item without touching anything else
  Future<void> updateStatus(String id, String newStatus) async {
    final item = state.firstWhere((i) => i.id == id);
    await _box?.put(id, item.copyWith(status: newStatus).toMap());
    _load();
  }
}

// ─── Main provider ────────────────────────────────────────────────────────────
final pantryProvider = StateNotifierProvider<PantryNotifier, List<PantryItem>>(
  (ref) => PantryNotifier(),
);

// ─── Derived providers ────────────────────────────────────────────────────────

// Total count — used in home screen stat card
final pantryCountProvider = Provider<int>(
  (ref) => ref.watch(pantryProvider).length,
);

// Only "Running Low" items — useful for home screen alerts
final runningLowProvider = Provider<List<PantryItem>>(
  (ref) => ref
      .watch(pantryProvider)
      .where((i) => i.status == 'Running Low')
      .toList(),
);

// Only "Out of Stock" items
final outOfStockProvider = Provider<List<PantryItem>>(
  (ref) => ref
      .watch(pantryProvider)
      .where((i) => i.status == 'Out of Stock')
      .toList(),
);
