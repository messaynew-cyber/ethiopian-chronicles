import 'package:flutter/material.dart';

class AppTheme {
  // OLED foundation
  static const Color background = Color(0xFF07070d);
  static const Color surface = Color(0xFF0d0d18);
  static const Color surfaceLight = Color(0xFF161625);
  static const Color cardGlass = Color(0x10ffffff);

  // Era accent colors (used sparingly — for active states, highlights)
  static const Color aksumGold = Color(0xFFd4a843);
  static const Color solomonicCrimson = Color(0xFFc41e3a);
  static const Color gondarineAmber = Color(0xFFe8a838);
  static const Color modernGreen = Color(0xFF2e7d32);
  static const Color battleRed = Color(0xFFb71c1c);

  // Text — bright and legible on OLED
  static const Color textPrimary = Color(0xFFf5f3eb);    // warm cream
  static const Color textTitle = Color(0xFFf0dfb8);      // warmer cream for titles
  static const Color textSecondary = Color(0xFFb0ad9e);  // bright grey (was dim)
  static const Color textMuted = Color(0xFF706d62);      // muted but readable

  // Glass / premium effects
  static const Color glassBorder = Color(0x15ffffff);
  static const Color glassBorderBright = Color(0x30ffffff);
  static const Color glassFill = Color(0x0affffff);

  // Achievements
  static const Color achievementGold = Color(0xFFd4a843);
  static const Color achievementSilver = Color(0xFFc0c0c0);
  static const Color achievementBronze = Color(0xFFcd7f32);

  // Parchment texture colors
  static const Color parchmentBase = Color(0xFF07070d);
  static const Color parchmentGrain = Color(0x03ffffff);

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
      backgroundColor: background,
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

  // Glass card with subtle border
  static BoxDecoration glassCard({Color? borderColor, double opacity = 0.10}) => BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borderColor?.withOpacity(0.25) ?? glassBorder, width: 0.8),
  );

  // Frosted glass for locked content — clearly visible as content
  static BoxDecoration frostedCard({Color? tint}) => BoxDecoration(
    color: (tint ?? aksumGold).withOpacity(0.04),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
  );

  // Era-to-accent-color
  static Color eraColor(String eraId) {
    switch (eraId) {
      case 'aksumite': return aksumGold;
      case 'zagwe': return const Color(0xFF9b7ce8);
      case 'solomonic': return solomonicCrimson;
      case 'gondarine': return gondarineAmber;
      case 'zemene': return const Color(0xFFa0802a);
      case 'modern': return modernGreen;
      case 'adwa': return battleRed;
      default: return aksumGold;
    }
  }

  // Custom icon paths — thin-line vector style, no emojis
  static IconData eraIcon(String eraId) {
    switch (eraId) {
      case 'aksumite': return Icons.account_balance;
      case 'zagwe': return Icons.church;
      case 'solomonic': return Icons.local_fire_department;
      case 'gondarine': return Icons.castle;
      case 'zemene': return Icons.shield;
      case 'modern': return Icons.flag;
      case 'adwa': return Icons.military_tech;
      default: return Icons.auto_stories;
    }
  }

  // Era Amharic name
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

  // Parchment texture — subtle noise pattern
  static BoxDecoration parchmentOverlay() => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        parchmentGrain,
        Colors.transparent,
        Colors.transparent,
      ],
    ),
  );
}
