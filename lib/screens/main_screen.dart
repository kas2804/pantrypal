import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import 'home/home_screen.dart';
import 'shopping/shopping_screen.dart';
import 'recipes/recipes_screen.dart';
import 'pantry/pantry_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(navIndexProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: IndexedStack(
        index: idx,
        children: const [
          HomeScreen(),
          ShoppingScreen(),
          RecipesScreen(),
          PantryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.teal),
            label: AppStrings.get('nav_home', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(
              Icons.shopping_cart,
              color: AppColors.teal,
            ),
            label: AppStrings.get('nav_shopping', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: AppColors.teal),
            label: AppStrings.get('nav_recipes', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: const Icon(Icons.kitchen, color: AppColors.teal),
            label: AppStrings.get('nav_pantry', lang),
          ),
        ],
      ),
    );
  }
}
