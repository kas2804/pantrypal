import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/pantry_item.dart';
import '../../models/shopping_item.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/shopping_provider.dart';
import 'add_pantry_item_screen.dart';
import '../../providers/language_provider.dart';
import '../../constants/app_strings.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(pantryProvider);
    final inStock = items.where((i) => i.status == 'In Stock').length;
    final low = items.where((i) => i.status == 'Running Low').length;
    final outOfStock = items.where((i) => i.status == 'Out of Stock').length;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppStrings.get('nav_pantry', lang)),
            if (items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
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
      body: Column(
        children: [
          // ── Stats bar ──────────────────────────────────────────────────
          if (items.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  _StatBadge('✅ In Stock', inStock, AppColors.teal),
                  const SizedBox(width: 8),
                  _StatBadge('⚡ Running Low', low, AppColors.orange),
                  const SizedBox(width: 8),
                  _StatBadge('❌ Out', outOfStock, const Color(0xFFE74C3C)),
                ],
              ),
            ),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? _EmptyState(lang)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _PantryCard(item: items[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPantryItemScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Stat Badge ───────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatBadge(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pantry Card ──────────────────────────────────────────────────────────────
class _PantryCard extends ConsumerWidget {
  final PantryItem item;
  const _PantryCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'In Stock':
        return AppColors.teal;
      case 'Running Low':
        return AppColors.orange;
      default:
        return const Color(0xFFE74C3C);
    }
  }

  // Returns what the status should become after one tap
  String get _nextStatus {
    switch (item.status) {
      case 'In Stock':
        return 'Running Low';
      case 'Running Low':
        return 'Out of Stock';
      default:
        return 'In Stock';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor;

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) =>
                ref.read(pantryProvider.notifier).deleteItem(item.id),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Left colour accent bar
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Category emoji
            Text(
              AppConstants.emojiForCategory(item.category),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),

            // Name + quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status badge — tap to cycle
            GestureDetector(
              onTap: () => ref
                  .read(pantryProvider.notifier)
                  .updateStatus(item.id, _nextStatus),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Quick add to shopping list
            GestureDetector(
              onTap: () {
                ref
                    .read(shoppingProvider.notifier)
                    .addItem(
                      ShoppingItem(
                        name: item.name,
                        category: item.category,
                        quantity: item.quantity,
                        unit: item.unit,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${item.name} added to shopping list',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.teal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.lightBeige,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String lang;
  const _EmptyState(this.lang);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥦', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('pantry_empty', lang),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track what you have at home',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
