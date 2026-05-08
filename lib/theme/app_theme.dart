import 'package:flutter/material.dart';

class AppTheme {
  // Ethiopian earth-tone palette on OLED black foundation
  static const Color background = Color(0xFF07070d);
  static const Color surface = Color(0xFF12121a);
  static const Color surfaceLight = Color(0xFF1a1a24);
  static const Color cardGlass = Color(0x18ffffff);
  static const Color stoneColor = Color(0xFF1a1a24);

  // Era colors
  static const Color aksumGold = Color(0xFFd4a843);
  static const Color solomonicCrimson = Color(0xFFc41e3a);
  static const Color gondarineAmber = Color(0xFFe8a838);
  static const Color modernGreen = Color(0xFF2e7d32);
  static const Color battleRed = Color(0xFF8b0000);

  // Text
  static const Color textPrimary = Color(0xFFf0efe8);
  static const Color textSecondary = Color(0xFF98968b);
  static const Color textMuted = Color(0xFF5c5a52);

  // Achievements
  static const Color achievementGold = Color(0xFFd4a843);
  static const Color achievementSilver = Color(0xFFc0c0c0);
  static const Color achievementBronze = Color(0xFFcd7f32);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: aksumGold,
      secondary: solomonicCrimson,
      surface: surface,
      background: background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontFamily: 'serif',
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontFamily: 'serif', fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
      displayMedium: TextStyle(color: textPrimary, fontFamily: 'serif', fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: textPrimary, fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 17, height: 1.7, fontFamily: 'serif'),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 15, height: 1.6),
      labelLarge: TextStyle(color: textPrimary, fontSize: 13, fontFamily: 'monospace', letterSpacing: 2),
    ),
  );

  static BoxDecoration glassCard({Color? borderColor}) => BoxDecoration(
    color: cardGlass,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderColor?.withOpacity(0.2) ?? Colors.white12, width: 1),
    boxShadow: [
      BoxShadow(color: (borderColor ?? aksumGold).withOpacity(0.05), blurRadius: 20),
    ],
  );

  // Era-to-color mapping
  static Color eraColor(String eraId) {
    switch (eraId) {
      case 'aksumite': return aksumGold;
      case 'zagwe': return const Color(0xFF7b68ee);
      case 'solomonic': return solomonicCrimson;
      case 'gondarine': return gondarineAmber;
      case 'zemene': return const Color(0xFF8b6914);
      case 'modern': return modernGreen;
      case 'adwa': return battleRed;
      default: return aksumGold;
    }
  }

  // Era-to-emoji
  static String eraEmoji(String eraId) {
    switch (eraId) {
      case 'aksumite': return '🏛️';
      case 'zagwe': return '⛪';
      case 'solomonic': return '👑';
      case 'gondarine': return '🏰';
      case 'zemene': return '⚔️';
      case 'modern': return '🇪🇹';
      case 'adwa': return '🛡️';
      default: return '📜';
    }
  }

  // Era-to-Amharic name
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
}
