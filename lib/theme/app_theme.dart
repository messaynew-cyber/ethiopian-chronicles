import 'package:flutter/material.dart';

class AppTheme {
  // Architect's palette — deep charcoal foundation
  static const Color background = Color(0xFF0F0F12);
  static const Color surface = Color(0xFF1C1C21);
  static const Color surfaceLight = Color(0xFF25252B);
  static const Color cardActive = Color(0xFF1C1C21);

  // Accent — Antique Gold
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentDim = Color(0xFFB8960A);
  static const Color accentGlow = Color(0x30D4AF37);

  // Era-specific accent variations (still gold-based)
  static const Color eraGold = Color(0xFFD4AF37);
  static const Color eraCrimson = Color(0xFFA0522D);
  static const Color eraAmber = Color(0xFFC8963E);
  static const Color eraGreen = Color(0xFF5B8C5A);
  static const Color eraRed = Color(0xFFC4554D);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textTitle = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFFC0BEB5);
  static const Color textMuted = Color(0xFF7A7870);

  // Glass
  static const Color glassBorder = Color(0x18FFFFFF);
  static const Color glassFill = Color(0x08FFFFFF);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: eraCrimson,
      surface: surface,
      background: background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 20, fontFamily: 'serif', fontWeight: FontWeight.w700, letterSpacing: 1.5,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontFamily: 'serif', fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2, height: 1.1),
      displayMedium: TextStyle(color: textPrimary, fontFamily: 'serif', fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
      headlineMedium: TextStyle(color: textTitle, fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w600, height: 1.2),
      titleLarge: TextStyle(color: textTitle, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 17, height: 1.85, fontFamily: 'serif'),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 15, height: 1.7, letterSpacing: 0.3),
      labelLarge: TextStyle(color: textPrimary, fontSize: 13, fontFamily: 'monospace', letterSpacing: 2),
      labelSmall: TextStyle(color: textMuted, fontSize: 11, fontFamily: 'monospace', letterSpacing: 3),
    ),
  );

  static BoxDecoration glassCard({Color? borderColor, double opacity = 0.06}) => BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borderColor?.withOpacity(0.3) ?? glassBorder, width: 0.8),
  );

  static BoxDecoration frostedCard({Color? tint}) => BoxDecoration(
    color: (tint ?? accent).withOpacity(0.04),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
  );

  static Color eraColor(String eraId) {
    switch (eraId) {
      case 'aksumite': return eraGold;
      case 'zagwe': return const Color(0xFF9B8EC8);
      case 'solomonic': return eraCrimson;
      case 'gondarine': return eraAmber;
      case 'zemene': return const Color(0xFFB8956E);
      case 'modern': return eraGreen;
      case 'adwa': return eraRed;
      default: return accent;
    }
  }

  static IconData eraIcon(String eraId) {
    switch (eraId) {
      case 'aksumite': return Icons.account_balance;
      case 'zagwe': return Icons.church_outlined;
      case 'solomonic': return Icons.local_fire_department;
      case 'gondarine': return Icons.castle_outlined;
      case 'zemene': return Icons.shield_outlined;
      case 'modern': return Icons.flag_outlined;
      case 'adwa': return Icons.military_tech;
      default: return Icons.auto_stories;
    }
  }

  static String eraAmharic(String eraId) {
    switch (eraId) {
      case 'aksumite': return 'አክሱም';
      case 'zagwe': return 'ዛግዌ';
      case 'solomonic': return 'ሰለሞናዊ';
      case 'gondarine': return 'ጎንደር';
      case 'zemene': return 'ዘመነ መሳፍንት';
      case 'modern': return 'ዘመናዊ';
      case 'adwa': return 'ዓድዋ';
      default: return '';
    }
  }

  static BoxDecoration parchmentOverlay() => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter, radius: 1.5,
      colors: [const Color(0x03FFFFFF), Colors.transparent, Colors.transparent],
    ),
  );
}
