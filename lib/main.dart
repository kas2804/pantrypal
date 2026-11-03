import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensures Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (our local database) — stores data on the phone
  await Hive.initFlutter();

  runApp(
    // ProviderScope = turns on Riverpod for the whole app
    const ProviderScope(child: PantryPalApp()),
  );
}

// ConsumerWidget = a widget that can READ from Riverpod providers
class PantryPalApp extends ConsumerWidget {
  const PantryPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PantryPal',
      debugShowCheckedModeBanner: false, // removes the red DEBUG banner
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Day 5: we'll make this switchable
      home: const MainScreen(),
    );
  }
}
