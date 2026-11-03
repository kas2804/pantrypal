import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
//import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('settings', lang))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Appearance ────────────────────────────────────────────────
          //const _SectionLabel('🎨  Appearance'),
          const SizedBox(height: 10),

          // ── Language ──────────────────────────────────────────────────
          _SectionLabel('🌐  ${AppStrings.get('language', lang)}'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _LangChip(
                  label: 'English',
                  flag: '🇬🇧',
                  value: 'en',
                  selected: lang == 'en',
                ),
                const SizedBox(width: 12),
                _LangChip(
                  label: 'हिंदी',
                  flag: '🇮🇳',
                  value: 'hi',
                  selected: lang == 'hi',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── About ─────────────────────────────────────────────────────
          const _SectionLabel('ℹ️  About'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🥦', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PantryPal',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
                          ),
                        ),
                        Text(
                          AppStrings.get('version', lang),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get('made_with', lang),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }
}

class _LangChip extends ConsumerWidget {
  final String label;
  final String flag;
  final String value;
  final bool selected;
  const _LangChip({
    required this.label,
    required this.flag,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.teal : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
