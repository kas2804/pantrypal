import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';

class ItemCard extends ConsumerWidget {
  final ShoppingItem item;
  const ItemCard({super.key, required this.item});

  // Priority colour coding
  Color get _priorityColor {
    switch (item.priority) {
      case 'High':
        return const Color(0xFFE74C3C); // red
      case 'Low':
        return AppColors.teal;
      default:
        return AppColors.orange; // medium
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shoppingProvider.notifier);

    return Slidable(
      key: ValueKey(item.id),

      // ── Swipe RIGHT → Favourite ─────────────────────────────────────────
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => notifier.toggleFavourite(item.id),
            backgroundColor: AppColors.pink,
            foregroundColor: Colors.white,
            icon: item.isFavourite ? Icons.favorite : Icons.favorite_border,
            label: item.isFavourite ? 'Unfav' : 'Fav',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
          ),
        ],
      ),

      // ── Swipe LEFT → Delete ─────────────────────────────────────────────
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => notifier.deleteItem(item.id),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
          ),
        ],
      ),

      // ── Card Body ───────────────────────────────────────────────────────
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: item.isTicked
              ? Colors.grey.shade100
              : Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: item.isTicked
              ? null
              : Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // ── Animated Checkbox ────────────────────────────────────────
            GestureDetector(
              onTap: () => notifier.toggleTick(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: item.isTicked ? AppColors.teal : Colors.transparent,
                  border: Border.all(
                    color: item.isTicked
                        ? AppColors.teal
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.isTicked
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // ── Category Emoji ───────────────────────────────────────────
            Text(
              AppConstants.emojiForCategory(item.category),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),

            // ── Name + Details ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.isTicked ? Colors.grey : AppColors.darkText,
                      decoration: item.isTicked
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        // Show 2.0 as "2" but 2.5 as "2.5"
                        '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (item.store != 'Any') ...[
                        Text(' · ', style: TextStyle(color: Colors.grey[400])),
                        Text(
                          item.store,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '📝 ${item.notes}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Right Side: Priority + icons ─────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.priority,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.isFavourite) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.favorite, color: AppColors.pink, size: 15),
                ],
                if (item.isRepeating) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.repeat, color: AppColors.teal, size: 15),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
