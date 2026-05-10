import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════ FOUNDATION — Warm Historical Palette ═══════════
  // V2: Layered premium colors inspired by Unseen Studio + Lacoste cloning patterns
  
  // Deep foundation — charcoal blacks with warmth
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141418);
  static const Color surfaceLight = Color(0xFF1E1E24);
  static const Color cardActive = Color(0xFF1A1A1F);

  // ═══════════ ACCENTS — Ethiopian Gold + Warm Tones ═══════════
  static const Color accent = Color(0xFFD4AF37);       // Antique gold
  static const Color accentBright = Color(0xFFE8C84A); // Bright gold (highlights)
  static const Color accentDim = Color(0xFFB8960A);     // Dim gold
  static const Color accentGlow = Color(0x30D4AF37);   // Gold glow

  // Warm cream/parchment tones (from Unseen Studio palette)
  static const Color parchment = Color(0xFFF5F0E8);
  static const Color cream = Color(0xFFEDE8E1);
  static const Color creamDim = Color(0xFFD4CFC5);
  static const Color amber = Color(0xFFD4A854);

  // Era-specific accent variations
  static const Color eraGold = Color(0xFFD4AF37);
  static const Color eraCrimson = Color(0xFFA0522D);
  static const Color eraAmber = Color(0xFFC8963E);
  static const Color eraGreen = Color(0xFF5B8C5A);
  static const Color eraRed = Color(0xFFC4554D);
  static const Color eraBlue = Color(0xFF4A6FA5);       // Kush / Nile blue
  static const Color eraPurple = Color(0xFF9B8EC8);     // Zagwe purple

  // ═══════════ TEXT ═══════════
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textTitle = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFFC0BEB5);
  static const Color textMuted = Color(0xFF7A7870);
  static const Color textCream = Color(0xFFE8E2DE);     // Warm text tint

  // ═══════════ GLASS & BORDERS ═══════════
  static const Color glassBorder = Color(0x12FFFFFF);
  static const Color glassFill = Color(0x06FFFFFF);
  static const Color glassHover = Color(0x0CFFFFFF);

  // ═══════════ PREMIUM LAYERS (from cloning patterns) ═══════════
  static const Color vignetteOverlay = Color(0x40000000);
  static const Color gridLine = Color(0x08FFFFFF);       // Blueprint grid lines
  static const Color spotlightCenter = Color(0x0AFFFFFF); // Radial spotlight center

  // ═══════════ THEME ═══════════
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

  // ═══════════ DECORATIONS ═══════════
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

  // V2: Premium card with cream accent line (Lacoste-inspired)
  static BoxDecoration premiumCard({Color? accent}) => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.8),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (accent ?? AppTheme.accent).withOpacity(0.04),
        Colors.transparent,
        Colors.transparent,
        (accent ?? AppTheme.accent).withOpacity(0.02),
      ],
    ),
  );

  // ═══════════ ERA HELPERS ═══════════
  static Color eraColor(String eraId) {
    switch (eraId) {
      case 'origins': return eraAmber;
      case 'kush': return eraBlue;
      case 'preaksumite': return const Color(0xFFB8956E);
      case 'aksumite': return eraGold;
      case 'zagwe': return eraPurple;
      case 'solomonic': return eraCrimson;
      case 'gondarine': return const Color(0xFFD4A854);
      case 'zemene': return const Color(0xFF8B7355);
      case 'modern': return eraGreen;
      case 'adwa': return eraRed;
      default: return accent;
    }
  }

  static IconData eraIcon(String eraId) {
    switch (eraId) {
      case 'origins': return Icons.stars;
      case 'kush': return Icons.shield;
      case 'preaksumite': return Icons.temple_hindu;
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
      case 'origins': return 'ትውፊታዊ አመጣጥ';
      case 'kush': return 'የኩሽ ሥርወ መንግሥት';
      case 'preaksumite': return 'ቅድመ-አክሱም';
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

  // ═══════════ V2: PREMIUM LAYERS ═══════════
  
  /// Subtle parchment texture overlay for reading screens
  static BoxDecoration parchmentOverlay() => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter, radius: 1.5,
      colors: [
        cream.withOpacity(0.03),
        Colors.transparent,
        Colors.transparent,
      ],
    ),
  );

  /// Blueprint-inspired subtle grid pattern
  static BoxDecoration blueprintGrid() => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 1.8,
      colors: [
        gridLine,
        Colors.transparent,
      ],
    ),
  );

  /// Warm spotlight gradient (Lacoste pattern)
  static BoxDecoration warmSpotlight() => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter, radius: 1.2,
      colors: [
        eraAmber.withOpacity(0.06),
        Colors.transparent,
      ],
    ),
  );
}
