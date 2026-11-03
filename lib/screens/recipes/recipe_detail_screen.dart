import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/recipe.dart';
import '../../models/shopping_item.dart';
import '../../providers/shopping_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late int _currentServings;

  @override
  void initState() {
    super.initState();
    // Start at the base servings the recipe was saved with
    _currentServings = widget.recipe.baseServings;
  }

  // How much to scale each ingredient
  // e.g. base=2, current=4 → multiplier=2.0 → quantities double
  double get _multiplier => _currentServings / widget.recipe.baseServings;

  // Adds every ingredient (scaled) to the shopping list
  void _addAllToCart() {
    final notifier = ref.read(shoppingProvider.notifier);

    for (final ing in widget.recipe.ingredients) {
      final scaled = ing.scale(_multiplier);
      notifier.addItem(
        ShoppingItem(
          name: scaled.name,
          category: scaled.category,
          quantity: scaled.quantity,
          unit: scaled.unit,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.recipe.ingredients.length} ingredients added to shopping list 🛒',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (recipe.description.isNotEmpty) ...[
                    Text(
                      recipe.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Serving Size Scaler ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Servings',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Minus
                        _ScalerButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_currentServings > 1) {
                              setState(() => _currentServings--);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_currentServings',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                        // Plus
                        _ScalerButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _currentServings++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Ingredients List ─────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Ingredients',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${recipe.ingredients.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                      // Show scaling label if not at base
                      if (_multiplier != 1.0) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '×${_multiplier % 1 == 0 ? _multiplier.toInt() : _multiplier.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...recipe.ingredients.map((ing) {
                    final scaled = ing.scale(_multiplier);
                    final qtyText = scaled.quantity % 1 == 0
                        ? scaled.quantity.toInt().toString()
                        : scaled.quantity.toStringAsFixed(1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppConstants.emojiForCategory(ing.category),
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ing.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Shows scaled quantity in teal
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '$qtyText ${ing.unit}',
                              key: ValueKey('$qtyText${ing.unit}'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Sticky Add to Cart Button ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addAllToCart,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  'Add all to Shopping List',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scaler +/- Button ────────────────────────────────────────────────────────
class _ScalerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ScalerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: AppColors.teal, size: 18),
      ),
    );
  }
}
