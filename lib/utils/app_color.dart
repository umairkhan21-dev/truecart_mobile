import 'package:flutter/material.dart';

class AppColor {
  static const Color background = Color(0xFF070910);
  static const Color surface = Color(0xFF111622);
  static const Color surfaceMuted = Color(0xFF1A2130);
  static const Color primary = Color(0xFF8B7CFF);
  static const Color secondary = Color(0xFF47D6FF);
  static const Color accent = Color(0xFF56E6B6);
  static const Color warning = Color(0xFFFFB454);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color gold = Color(0xFFFFD166);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8C2D6);
  static const Color textMuted = Color(0xFF758199);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF121829), Color(0xFF070910), Color(0xFF07131A)],
    stops: [0, 0.52, 1],
  );
}
