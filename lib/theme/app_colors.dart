import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(
    0xFFF5F6F8,
  ); // Light crisp grey for the app background
  static const Color card =
      Colors.white; // Pure white for form cards and inputs

  // 🛠️ THE FIX: Added 'panel' back in so your older screens don't crash!
  static const Color panel = Colors.white;

  // Typography
  static const Color textPrimary = Color(
    0xFF1A1A1A,
  ); // Deep black for readability
  static const Color textSecondary = Color(
    0xFF666666,
  ); // Mid-grey for subtext and hints

  // Brand / Accents (Multipoint Check / AA styling)
  static const Color primary = Color(
    0xFF0B132B,
  ); // Dark Navy for AppBars/Headers
  static const Color accent = Color(0xFFFFD700); // Signature Yellow/Gold
  static const Color gold = Color(0xFFD4AF37); // Standard Gold
  static const Color goldDark = Color(0xFFAA8B2C);

  // Status / Utility
  static const Color border = Color(0xFFE0E0E0); // Soft borders for light mode
  static const Color success = Color(0xFF2E7D32); // Pass (Green)
  static const Color error = Color(0xFFC62828); // Fail (Red)
}
