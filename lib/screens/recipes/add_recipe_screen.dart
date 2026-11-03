import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  final Recipe? recipe; // null = new recipe, non-null = editing existing
  const AddRecipeScreen({super.key, this.recipe});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _servings = 2;
  final List<RecipeIngredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill all fields with the existing recipe's data
    final r = widget.recipe;
    if (r != null) {
      _nameCtrl.text = r.name;
      _descCtrl.text = r.description;
      _servings = r.baseServings;
      _ingredients.addAll(r.ingredients);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _showAddIngredientSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IngredientSheet(
        onAdd: (ingredient) {
          setState(() => _ingredients.add(ingredient));
        },
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a recipe name',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add at least one ingredient',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final existing = widget.recipe;

    if (existing != null) {
      // ── EDIT MODE: keep the original id and createdAt ──────────────────
      ref
          .read(recipeProvider.notifier)
          .updateRecipe(
            Recipe(
              id: existing.id,
              name: name,
              description: _descCtrl.text.trim(),
              baseServings: _servings,
              ingredients: _ingredients,
              createdAt: existing
                  .createdAt, // preserve original date so sort order stays stable
            ),
          );
    } else {
      // ── ADD MODE ────────────────────────────────────────────────────────
      ref
          .read(recipeProvider.notifier)
          .addRecipe(
            Recipe(
              name: name,
              description: _descCtrl.text.trim(),
              baseServings: _servings,
              ingredients: _ingredients,
            ),
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        // Show "Edit Recipe" when editing, "New Recipe" when creating
        title: Text(isEditing ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Recipe Name ───────────────────────────────────────────────
            _label('Recipe Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(),
              decoration: _inputDeco('e.g. Mango Lassi', emoji: '🍳'),
            ),
            const SizedBox(height: 20),

            // ── Description ───────────────────────────────────────────────
            _label('Description  (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDeco('e.g. Quick summer drink', emoji: '📝'),
            ),
            const SizedBox(height: 20),

            // ── Servings ──────────────────────────────────────────────────
            _label('Base Servings'),
            const SizedBox(height: 4),
            Text(
              'Quantities will scale when you change servings later',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ServingButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_servings > 1) setState(() => _servings--);
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  '$_servings',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                _ServingButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _servings++),
                ),
                const SizedBox(width: 12),
                Text(
                  'people',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Ingredients ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Ingredients  (${_ingredients.length})'),
                TextButton.icon(
                  onPressed: _showAddIngredientSheet,
                  icon: const Icon(Icons.add, size: 18, color: AppColors.teal),
                  label: Text(
                    'Add',
                    style: GoogleFonts.poppins(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightBeige,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🥕', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(
                      'No ingredients yet',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tap Add above to start',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_ingredients.length, (i) {
                final ing = _ingredients[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppConstants.emojiForCategory(ing.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ing.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _ingredients.removeAt(i)),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 32),

            // ── Save Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes ✓' : 'Save Recipe ✓',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.darkText,
    ),
  );

  InputDecoration _inputDeco(String hint, {String? emoji}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
    prefixIcon: emoji != null
        ? Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          )
        : null,
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.teal, width: 2),
    ),
  );
}

// ─── Serving +/- Button ───────────────────────────────────────────────────────
class _ServingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ServingButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: AppColors.teal, size: 20),
      ),
    );
  }
}

// ─── Add Ingredient Bottom Sheet ──────────────────────────────────────────────
class _IngredientSheet extends StatefulWidget {
  final void Function(RecipeIngredient) onAdd;
  const _IngredientSheet({required this.onAdd});

  @override
  State<_IngredientSheet> createState() => _IngredientSheetState();
}

class _IngredientSheetState extends State<_IngredientSheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  String _unit = 'pcs';
  String _category = 'Veggies';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _add() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;
    widget.onAdd(
      RecipeIngredient(
        name: name,
        quantity: qty,
        unit: _unit,
        category: _category,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Ingredient',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: 'e.g. Basmati Rice',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              filled: true,
              fillColor: AppColors.lightBeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightBeige,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.units.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final u = AppConstants.units[i];
                      final sel = _unit == u;
                      return GestureDetector(
                        onTap: () => setState(() => _unit = u),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.orange
                                : AppColors.lightBeige,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              u,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppColors.darkText,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cat = AppConstants.categories[i];
                final lbl = cat['label']!;
                final sel = _category == lbl;
                return GestureDetector(
                  onTap: () => setState(() => _category = lbl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.teal : AppColors.lightBeige,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          cat['emoji']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lbl,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: sel ? Colors.white : AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _add,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Add Ingredient',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
