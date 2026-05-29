import 'package:flutter/material.dart';

class AppColors {
  // Primary Orange (main brand color)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C5A);
  static const Color primaryDark = Color(0xFFE55A25);
  static const Color primaryBg = Color(0xFFFFF3ED);
  
  // Ethiopian Flag Colors
  static const Color ethGreen = Color(0xFF078930);
  static const Color ethYellow = Color(0xFFFCDD09);
  static const Color ethRed = Color(0xFFDA121A);
  
  // Warm Tones
  static const Color warmGold = Color(0xFFFFB800);
  static const Color deepGold = Color(0xFFE5A100);
  static const Color terracotta = Color(0xFFCC5A3D);
  static const Color coffeeBrown = Color(0xFF6F4E37);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color beige = Color(0xFFF5EDE3);
  static const Color honey = Color(0xFFEB9605);
  
  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Macros
  static const Color proteinBlue = Color(0xFF3B82F6);
  static const Color carbsOrange = Color(0xFFF97316);
  static const Color fatRed = Color(0xFFEF4444);
  static const Color fiberGreen = Color(0xFF22C55E);
  
  // Water
  static const Color waterBlue = Color(0xFF0EA5E9);
  static const Color waterLight = Color(0xFFBAE6FD);
  
  // Calorie Ring Colors
  static const Color ringGreen = Color(0xFF22C55E);
  static const Color ringYellow = Color(0xFFF59E0B);
  static const Color ringOrange = Color(0xFFF97316);
  static const Color ringRed = Color(0xFFEF4444);
  static const Color ringDeepRed = Color(0xFFDC2626);
  
  // Light Theme
  static const Color lightScaffold = Color(0xFFFFFAF7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFF8F3);
  static const Color lightDivider = Color(0xFFE8DDD4);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  
  // Dark Theme
  static const Color darkScaffold = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF252540);
  static const Color darkDivider = Color(0xFF333355);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  
  // Gradient Presets
  static LinearGradient get orangeGradient => const LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get ethiopianGradient => const LinearGradient(
    colors: [Color(0xFF078930), Color(0xFFFCDD09)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get warmGradient => const LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get darkCardGradient => const LinearGradient(
    colors: [Color(0xFF252540), Color(0xFF1E1E38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
