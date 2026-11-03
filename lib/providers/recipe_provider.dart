import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────
class RecipeNotifier extends StateNotifier<List<Recipe>> {
  Box? _box;

  RecipeNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('recipes');
    _load();
  }

  void _load() {
    if (_box == null) return;
    final recipes = _box!.values.map((v) => Recipe.fromMap(v as Map)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    state = recipes;
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _box?.put(recipe.id, recipe.toMap());
    _load();
  }

  Future<void> deleteRecipe(String id) async {
    await _box?.delete(id);
    _load();
  }

  Future<void> updateRecipe(Recipe updated) async {
    await _box?.put(updated.id, updated.toMap());
    _load();
  }
}

// ─── Main provider ────────────────────────────────────────────────────────────
final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>(
  (ref) => RecipeNotifier(),
);

// ─── Derived providers ────────────────────────────────────────────────────────

// Total recipe count — used in home screen stat card
final recipeCountProvider = Provider<int>(
  (ref) => ref.watch(recipeProvider).length,
);
