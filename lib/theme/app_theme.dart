import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ☀️ Light Theme
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.orange,
      tertiary: AppColors.yellow,
      surface: Colors.white,
      surfaceContainerHighest: AppColors.tealLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: AppColors.darkText,
      primaryContainer: AppColors.tealLight,
      secondaryContainer: AppColors.orangeLight,
      tertiaryContainer: AppColors.yellowLight,
    ),
    scaffoldBackgroundColor: AppColors.lightBeige,
    textTheme: GoogleFonts.poppinsTextTheme(),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    // ── App Bar ──────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 255, 240, 249),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),

    // ── Bottom Navigation ────────────────────────────────────
    // Warm white bar, teal pill indicator, orange active icon
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: AppColors.orange.withValues(alpha: 0.10),
      indicatorColor: AppColors.teal.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.teal, size: 24);
        }
        return const IconThemeData(color: AppColors.greyText, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.teal,
          );
        }
        return GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.greyText,
        );
      }),
    ),

    // ── Cards ────────────────────────────────────────────────
    // Clean white base; use AppColors.orangeLight / tealLight
    // on individual cards for category pops (see categoryPairs)
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),

    // ── FAB ─────────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.orange, // switched to orange for contrast
      foregroundColor: Colors.white,
      shape: CircleBorder(),
      elevation: 4,
    ),

    // ── Chips (category tags, filters) ──────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.tealLight,
      selectedColor: AppColors.teal,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.teal,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Input / Search bar ───────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: GoogleFonts.poppins(color: AppColors.greyText, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      prefixIconColor: AppColors.teal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Elevated Button ──────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Outlined Button ──────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        side: const BorderSide(color: AppColors.teal, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Badge (cart count etc.) ──────────────────────────────
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.orange,
      textColor: Colors.white,
    ),
  );

  // 🌙 Dark Theme
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.teal,
      secondary: AppColors.orange,
      tertiary: AppColors.yellow,
      surface: AppColors.darkSurface,
      primaryContainer: Color(0xFF0A3D3D),
      secondaryContainer: Color(0xFF4A2510),
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.teal.withValues(alpha: 0.25),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.teal, size: 24);
        }
        return const IconThemeData(color: AppColors.greyText, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.teal,
          );
        }
        return GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.greyText,
        );
      }),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.orange,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF0A3D3D),
      selectedColor: AppColors.teal,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.teal,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      hintStyle: GoogleFonts.poppins(color: AppColors.greyText, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      prefixIconColor: AppColors.teal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.orange,
      textColor: Colors.white,
    ),
  );
}
