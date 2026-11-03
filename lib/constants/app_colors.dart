import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Tropical Punch Palette
  static const Color orange = Color(0xFFFF8243);
  static const Color pink = Color(0xFFFFC0CB);
  static const Color yellow = Color(0xFFFCE883);
  static const Color teal = Color(0xFF069494);

  // 🍊 Tinted surfaces (palette @ low opacity, pre-baked for performance)
  static const Color orangeLight = Color(0xFFFFEEE5); // orange @ ~10%
  static const Color pinkLight = Color(0xFFFFF0F3); // pink  @ ~10%
  static const Color yellowLight = Color(0xFFFFFBE6); // yellow @ ~12%
  static const Color tealLight = Color(0xFFE0F5F5); // teal  @ ~12%

  // 🤍 Neutrals
  static const Color beige = Color(0xFFFFF8F0);
  static const Color lightBeige = Color(0xFFFAF3E0);
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color greyText = Color(0xFF8A8A8A);
  static const Color divider = Color(0xFFEDE8DF);

  // 🌑 Dark Mode
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF3A3A3C);

  // 🌈 Gradients — use in banners, category chips, hero cards
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF8243), Color(0xFFFFAB76)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF069494), Color(0xFF08B8B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF8243), Color(0xFFFFC0CB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lemonGradient = LinearGradient(
    colors: [Color(0xFFFCE883), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🏷️ Category tag colours [bg, foreground] — cycle through for grocery cats
  static const List<List<Color>> categoryPairs = [
    [orangeLight, orange],
    [tealLight, teal],
    [pinkLight, Color(0xFFD4687A)],
    [yellowLight, Color(0xFFB8960A)],
  ];
}
