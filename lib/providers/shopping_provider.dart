import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

// ─── The Notifier ─────────────────────────────────────────────────────────────
class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  Box? _box;

  ShoppingNotifier() : super([]) {
    _init();
  }

  // Opens the Hive box and loads saved items
  Future<void> _init() async {
    _box = await Hive.openBox('shopping');
    _load();
  }

  // Reads all items from Hive and updates state
  void _load() {
    if (_box == null) return;
    final items =
        _box!.values.map((v) => ShoppingItem.fromMap(v as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    state = items;
  }

  // ─── Public methods ─────────────────────────────────────────────────────────

  Future<void> addItem(ShoppingItem item) async {
    await _box?.put(item.id, item.toMap());
    _load();
  }

  Future<void> deleteItem(String id) async {
    await _box?.delete(id);
    _load();
  }

  Future<void> toggleTick(String id) async {
    final item = state.firstWhere((i) => i.id == id);
    await _box?.put(id, item.copyWith(isTicked: !item.isTicked).toMap());
    _load();
  }

  Future<void> toggleFavourite(String id) async {
    final item = state.firstWhere((i) => i.id == id);
    await _box?.put(id, item.copyWith(isFavourite: !item.isFavourite).toMap());
    _load();
  }

  Future<void> toggleOftenBought(String id) async {
    final item = state.firstWhere((i) => i.id == id);
    await _box?.put(
      id,
      item.copyWith(isOftenBought: !item.isOftenBought).toMap(),
    );
    _load();
  }

  Future<void> updateItem(ShoppingItem updated) async {
    await _box?.put(updated.id, updated.toMap());
    _load();
  }

  // Deletes every ticked item in one go
  Future<void> clearTicked() async {
    final tickedIds = state.where((i) => i.isTicked).map((i) => i.id).toList();
    for (final id in tickedIds) {
      await _box?.delete(id);
    }
    _load();
  }
}

// ─── Main provider ────────────────────────────────────────────────────────────
final shoppingProvider =
    StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>(
      (ref) => ShoppingNotifier(),
    );

// ─── Derived (filtered) providers ────────────────────────────────────────────

// All items not yet ticked
final untickedProvider = Provider<List<ShoppingItem>>(
  (ref) => ref.watch(shoppingProvider).where((i) => !i.isTicked).toList(),
);

// All ticked items
final tickedProvider = Provider<List<ShoppingItem>>(
  (ref) => ref.watch(shoppingProvider).where((i) => i.isTicked).toList(),
);

// Favourites only
final favouritesProvider = Provider<List<ShoppingItem>>(
  (ref) => ref.watch(shoppingProvider).where((i) => i.isFavourite).toList(),
);

// Often bought only
final oftenBoughtProvider = Provider<List<ShoppingItem>>(
  (ref) => ref.watch(shoppingProvider).where((i) => i.isOftenBought).toList(),
);

// Count of unticked items (used in home screen stat card)
final toBuyCountProvider = Provider<int>(
  (ref) => ref.watch(untickedProvider).length,
);
