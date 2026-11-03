import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/shopping_item.dart';
import '../../models/pantry_item.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/pantry_provider.dart';
import '../main_screen.dart';
import '../../constants/app_strings.dart';
import '../../providers/language_provider.dart';
import '../settings/settings_screen.dart';

// All items marked as repeating — shown in Recurring section
final repeatingItemsProvider = Provider<List<ShoppingItem>>(
  (ref) => ref.watch(shoppingProvider).where((i) => i.isRepeating).toList(),
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final unticked = ref.watch(untickedProvider);
    final repeating = ref.watch(repeatingItemsProvider);
    final runningLow = ref.watch(runningLowProvider);
    final outOfStock = ref.watch(outOfStockProvider);

    // Max 5 items shown on home — the rest are behind "See more"
    final todayItems = unticked.take(5).toList();
    final moreCount = unticked.length - todayItems.length;

    // Items worth alerting the user about in the pantry
    final alertItems = [...outOfStock, ...runningLow];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              _buildHeader(ref),
              const SizedBox(height: 24),

              // ── Stats ────────────────────────────────────────────────────
              _buildStatsRow(ref),

              // ── Pantry Alert (only if something is low/out) ─────────────
              if (alertItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                _PantryAlertBanner(items: alertItems),
              ],
              const SizedBox(height: 24),

              // ── Today's List ─────────────────────────────────────────────
              _SectionHeader(
                title: AppStrings.get('todays_list', lang),
                count: unticked.isEmpty ? null : unticked.length,
                actionLabel: unticked.isNotEmpty
                    ? AppStrings.get('see_all', lang)
                    : null,
                onAction: unticked.isNotEmpty
                    ? () => ref.read(navIndexProvider.notifier).state = 1
                    : null,
              ),
              const SizedBox(height: 12),

              if (unticked.isEmpty)
                _buildEmptyList(ref)
              else
                Column(
                  children: [
                    ...todayItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _HomeItemTile(item: item),
                      ),
                    ),
                    if (moreCount > 0) ...[
                      const SizedBox(height: 4),
                      _buildSeeMoreButton(moreCount, ref),
                    ],
                  ],
                ),

              // ── Recurring Items ───────────────────────────────────────────
              // ── Recurring Items ───────────────────────────────────────────
              if (repeating.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHeader(
                  title: AppStrings.get('recurring', lang),
                ), // Added missing ) and , here!
                const SizedBox(height: 12),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: repeating.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _RepeatingChip(item: repeating[i]),
                  ),
                ),
              ],

              // ── Categories ────────────────────────────────────────────────
              const SizedBox(height: 28),
              _SectionHeader(title: AppStrings.get('categories', lang)),
              const SizedBox(height: 12),
              _buildCategoryGrid(ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final h = DateTime.now().hour;
    final greeting = h < 12
        ? AppStrings.get('good_morning', lang)
        : h < 17
        ? AppStrings.get('good_afternoon', lang)
        : AppStrings.get('good_evening', lang);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(
              AppStrings.get('whats_on_list', lang),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        // Avatar now tappable — opens Settings
        GestureDetector(
          onTap: () => Navigator.push(
            ref.context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ─── Stats Row ───────────────────────────────────────────────────────────

  Widget _buildStatsRow(WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final toBuy = ref.watch(toBuyCountProvider);
    final recipes = ref.watch(recipeCountProvider);
    final pantry = ref.watch(pantryCountProvider);
    return Row(
      children: [
        _StatCard(
          emoji: '🛒',
          label: AppStrings.get('to_buy', lang),
          value: '$toBuy',
          color: AppColors.orange,
        ),
        _StatCard(
          emoji: '📖',
          label: AppStrings.get('recipes', lang),
          value: '$recipes',
          color: AppColors.teal,
        ),
        _StatCard(
          emoji: '🥦',
          label: AppStrings.get('in_pantry', lang),
          value: '$pantry',
          color: const Color(0xFF9B59B6),
        ),
      ],
    );
  }

  // ─── Empty List ──────────────────────────────────────────────────────────
  Widget _buildEmptyList(WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(navIndexProvider.notifier).state = 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.pink.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Text('🛍️', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(
              'Your list is empty!',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap here to go add items →',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── See More Button ─────────────────────────────────────────────────────
  Widget _buildSeeMoreButton(int count, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(navIndexProvider.notifier).state = 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            'See $count more item${count > 1 ? 's' : ''} →',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Category Grid ───────────────────────────────────────────────────────
  Widget _buildCategoryGrid(WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.88,
      children: AppConstants.categories
          .map(
            (c) => GestureDetector(
              // Tapping a category switches to Shopping tab
              onTap: () => ref.read(navIndexProvider.notifier).state = 1,
              child: _CategoryTile(emoji: c['emoji']!, label: c['label']!),
            ),
          )
          .toList(),
    );
  }
}

// ─── Pantry Alert Banner ──────────────────────────────────────────────────────
class _PantryAlertBanner extends ConsumerWidget {
  final List<PantryItem> items;
  const _PantryAlertBanner({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outCount = items.where((i) => i.status == 'Out of Stock').length;
    final lowCount = items.where((i) => i.status == 'Running Low').length;

    String message;
    if (outCount > 0 && lowCount > 0) {
      message = '$outCount out of stock · $lowCount running low';
    } else if (outCount > 0) {
      message = '$outCount item${outCount > 1 ? 's' : ''} out of stock';
    } else {
      message = '$lowCount item${lowCount > 1 ? 's' : ''} running low';
    }

    return GestureDetector(
      // Tap banner → switch to Pantry tab
      onTap: () => ref.read(navIndexProvider.notifier).state = 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE74C3C).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pantry Alert',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE74C3C),
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFE74C3C), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal),
            ),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Text(
              '$actionLabel →',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Home Item Tile ───────────────────────────────────────────────────────────
// Simpler than the full ItemCard — tap anywhere to tick, no swipe actions
class _HomeItemTile extends ConsumerWidget {
  final ShoppingItem item;
  const _HomeItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(shoppingProvider.notifier).toggleTick(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: item.isTicked ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Animated checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isTicked ? AppColors.teal : Colors.transparent,
                border: Border.all(
                  color: item.isTicked ? AppColors.teal : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: item.isTicked
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null,
            ),
            const SizedBox(width: 12),

            // Category emoji
            Text(
              AppConstants.emojiForCategory(item.category),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),

            // Name
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.isTicked ? Colors.grey : AppColors.darkText,
                  decoration: item.isTicked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey,
                ),
              ),
            ),

            // Quantity + unit
            Text(
              '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),

            // Priority dot
            if (!item.isTicked) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.priority == 'High'
                      ? const Color(0xFFE74C3C)
                      : item.priority == 'Low'
                      ? AppColors.teal
                      : AppColors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Recurring Item Chip ──────────────────────────────────────────────────────
class _RepeatingChip extends StatelessWidget {
  final ShoppingItem item;
  const _RepeatingChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppConstants.emojiForCategory(item.category),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.repeatFrequency,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final String emoji;
  final String label;
  const _CategoryTile({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
