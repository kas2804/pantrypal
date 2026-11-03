import 'package:uuid/uuid.dart';

// ─── Ingredient (lives inside a Recipe) ──────────────────────────────────────
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;
  final String category; // same categories as shopping items

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
  });

  // Scale quantity by a multiplier (used for serving size scaler)
  // e.g. ingredient.scale(2) doubles the quantity
  RecipeIngredient scale(double multiplier) => RecipeIngredient(
    name: name,
    quantity: quantity * multiplier,
    unit: unit,
    category: category,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'category': category,
  };

  factory RecipeIngredient.fromMap(Map map) => RecipeIngredient(
    name: map['name'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'] as String,
    category: map['category'] as String? ?? 'Other',
  );
}

// ─── Recipe ───────────────────────────────────────────────────────────────────
class Recipe {
  final String id;
  final String name;
  final String description; // optional subtitle / notes
  final int baseServings; // how many people this recipe is for
  final List<RecipeIngredient> ingredients;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.name,
    this.description = '',
    this.baseServings = 2,
    required this.ingredients,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Returns a copy of this recipe with some fields changed
  Recipe copyWith({
    String? name,
    String? description,
    int? baseServings,
    List<RecipeIngredient>? ingredients,
  }) => Recipe(
    id: id,
    createdAt: createdAt,
    name: name ?? this.name,
    description: description ?? this.description,
    baseServings: baseServings ?? this.baseServings,
    ingredients: ingredients ?? this.ingredients,
  );

  // ── Serialisation ────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'baseServings': baseServings,
    // Each ingredient is also converted to a map
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recipe.fromMap(Map map) => Recipe(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    baseServings: map['baseServings'] as int? ?? 2,
    // Each saved map is converted back into a RecipeIngredient
    ingredients: (map['ingredients'] as List)
        .map((i) => RecipeIngredient.fromMap(i as Map))
        .toList(),
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
