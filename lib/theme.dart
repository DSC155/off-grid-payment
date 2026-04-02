import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF8B5CF6);       // Electric Violet
  static const Color primaryLight = Color(0xFFA78BFA);  // Soft Violet
  static const Color primaryDark = Color(0xFF6D28D9);   // Deep Violet
  static const Color accent = Color(0xFFF59E0B);        // Amber Gold
  static const Color accentCool = Color(0xFF06B6D4);    // Cyan

  // ── Backgrounds ────────────────────────────────────────────────
  static const Color bg = Color(0xFF0D0D0D);            // Pure black
  static const Color bgSurface = Color(0xFF161616);     // Slightly lighter
  static const Color bgCard = Color(0xFF1C1C1E);        // iOS-style dark card
  static const Color bgElevated = Color(0xFF242428);    // Elevated surface
  static const Color bgInput = Color(0xFF1A1A1E);       // Input field bg

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);  // Zinc-400
  static const Color textMuted = Color(0xFF52525B);       // Zinc-600
  static const Color textHint = Color(0xFF3F3F46);        // Zinc-700

  // ── Status ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);   // Emerald
  static const Color danger = Color(0xFFEF4444);    // Red
  static const Color warning = Color(0xFFF59E0B);   // Amber

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sendGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient receiveGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF065F46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient addGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Typography ─────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.8,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textMuted,
    letterSpacing: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textMuted,
    letterSpacing: 0.2,
  );

  // ── Border Radius ──────────────────────────────────────────────
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusXxl = 32;

  // ── Borders ────────────────────────────────────────────────────
  static Border get subtleBorder => Border.all(
    color: const Color(0xFF2A2A2E),
    width: 1,
  );

  static Border get primaryBorder => Border.all(
    color: primary.withOpacity(0.4),
    width: 1,
  );

  // ── Shadows & Glows ────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.6),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get glowPurple => [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get glowAmber => [
    BoxShadow(
      color: accent.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get glowGreen => [
    BoxShadow(
      color: success.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -4,
    ),
  ];
}
