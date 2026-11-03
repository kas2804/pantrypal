import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/shopping_item.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/item_card.dart';
import 'add_item_screen.dart';
import '../../providers/language_provider.dart';
import '../../constants/app_strings.dart';

// Which category chip is selected
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Category-filtered unticked items (search applied on top in the widget)
final filteredUntickedProvider = Provider<List<ShoppingItem>>((ref) {
  final items = ref.watch(untickedProvider);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == 'All') return items;
  if (cat == 'Fav') return items.where((i) => i.isFavourite).toList();
  return items.where((i) => i.category == cat).toList();
});

// ─── Screen ───────────────────────────────────────────────────────────────────
class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Filters a list by search query — case insensitive, matches anywhere in name
  List<ShoppingItem> _applySearch(List<ShoppingItem> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  // Confirmation dialog before clearing bought items
  void _confirmClearBought() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Bought Items?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This permanently removes all ticked items from your list.',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(shoppingProvider.notifier).clearTicked();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE74C3C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider data
    final lang = ref.watch(languageProvider);
    final filteredUnticked = _applySearch(ref.watch(filteredUntickedProvider));
    final ticked = _applySearch(ref.watch(tickedProvider));
    final allUnticked = ref.watch(untickedProvider); // raw count for badge
    final often = ref.watch(oftenBoughtProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    final isEmpty = allUnticked.isEmpty && ref.watch(tickedProvider).isEmpty;
    // Show 🎉 when everything is ticked and search is clear
    final allDone =
        allUnticked.isEmpty &&
        ref.watch(tickedProvider).isNotEmpty &&
        _searchQuery.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppStrings.get('shopping_list', lang)),
            if (allUnticked.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${allUnticked.length}',
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
        actions: [
          // Clear bought — only visible when there are ticked items
          if (ref.watch(tickedProvider).isNotEmpty)
            IconButton(
              onPressed: _confirmClearBought,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear bought items',
              color: const Color(0xFFE74C3C),
            ),
        ],
      ),

      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.greyText,
                  size: 20,
                ),
                // X button to clear search
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.greyText,
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.lightBeige,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category Filter Chips ───────────────────────────────────────
          _FilterChips(selectedCat: selectedCat),

          // ── Main List ───────────────────────────────────────────────────
          Expanded(
            child: isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    children: [
                      // All done celebration card
                      if (allDone) _AllDoneCard(),

                      // Often Bought — horizontal scroll
                      if (often.isNotEmpty &&
                          selectedCat == 'All' &&
                          _searchQuery.isEmpty) ...[
                        _SectionHeader(
                          title: '⚡ Often Bought',
                          count: often.length,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: often.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) =>
                                _OftenBoughtChip(item: often[i]),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // To Buy list
                      if (filteredUnticked.isNotEmpty) ...[
                        _SectionHeader(
                          title: '🛒 To Buy',
                          count: filteredUnticked.length,
                        ),
                        const SizedBox(height: 10),
                        ...filteredUnticked.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ItemCard(item: item),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // No search results
                      if (_searchQuery.isNotEmpty &&
                          filteredUnticked.isEmpty &&
                          ticked.isEmpty)
                        _NoResultsCard(query: _searchQuery),

                      // Bought list
                      if (ticked.isNotEmpty) ...[
                        _SectionHeader(title: '✅ Bought', count: ticked.length),
                        const SizedBox(height: 10),
                        ...ticked.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ItemCard(item: item),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),

      // Add heroTag: null right here!
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────
class _FilterChips extends ConsumerWidget {
  final String selectedCat;
  const _FilterChips({required this.selectedCat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = [
      {'emoji': '🌟', 'label': 'All'},
      {'emoji': '❤️', 'label': 'Fav'},
      ...AppConstants.categories,
    ];

    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = chips[i]['label']!;
          final emoji = chips[i]['emoji']!;
          final isSelected = selectedCat == label;
          return GestureDetector(
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal : AppColors.lightBeige,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.teal : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
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
    );
  }
}

// ─── Often Bought Chip ────────────────────────────────────────────────────────
class _OftenBoughtChip extends ConsumerWidget {
  final ShoppingItem item;
  const _OftenBoughtChip({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref
          .read(shoppingProvider.notifier)
          .addItem(
            ShoppingItem(
              name: item.name,
              category: item.category,
              quantity: item.quantity,
              unit: item.unit,
              priority: item.priority,
              store: item.store,
            ),
          ),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.yellow, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstants.emojiForCategory(item.category),
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── All Done Card ────────────────────────────────────────────────────────────
class _AllDoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            'All done!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Great shopping trip! 🛒',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ─── No Search Results ────────────────────────────────────────────────────────
class _NoResultsCard extends StatelessWidget {
  final String query;
  const _NoResultsCard({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different name',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Your list is empty!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first item',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
