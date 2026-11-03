import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';
import '../../providers/language_provider.dart';
import '../../constants/app_strings.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppStrings.get('recipes', lang)),
            if (recipes.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${recipes.length}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: recipes.isEmpty
          ? _buildEmptyState(lang)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _RecipeCard(recipe: recipes[i]),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('no_recipes', lang),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to save your first recipe',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─── Recipe Card ──────────────────────────────────────────────────────────────
class _RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey(recipe.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.50, // wider to fit both Edit + Delete buttons
        children: [
          // ── Edit button ──────────────────────────────────────────────────
          SlidableAction(
            onPressed: (_) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddRecipeScreen(recipe: recipe), // pass recipe for pre-fill
              ),
            ),
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
          // ── Delete button ─────────────────────────────────────────────────
          SlidableAction(
            onPressed: (_) =>
                ref.read(recipeProvider.notifier).deleteRecipe(recipe.id),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              // ── Recipe image (replaces the 🍳 emoji) ────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/recipe.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),

              // ── Name + description + chips ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    if (recipe.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        recipe.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoChip(
                          '${recipe.ingredients.length} ingredients',
                          AppColors.teal,
                        ),
                        const SizedBox(width: 6),
                        _InfoChip(
                          '${recipe.baseServings} servings',
                          AppColors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
