import 'package:flutter/material.dart';
import '../theme.dart';

/// All shipped themes, in the order they appear in the picker.
class AppThemes {
  AppThemes._();

  static const List<AppTheme> all = [
    purpleSynthwave,
    neonGrid,
    miami,
    outrun,
    tron,
    vaporwave,
    hotline,
    mandalorian,
    dark,
    light,
    paper,
    highContrast,
  ];

  static AppTheme byId(String id) => all.firstWhere(
        (t) => t.id == id,
        orElse: () => defaultTheme,
      );

  static const AppTheme defaultTheme = purpleSynthwave;

  // ══════════════════════════════════════════════════════
  //  SYNTHWAVE VARIANTS
  // ══════════════════════════════════════════════════════

  static const AppTheme purpleSynthwave = AppTheme(
    id: 'purple_synthwave',
    name: 'Purple Synthwave',
    tagline: 'The Wave // Default',
    brightness: Brightness.dark,
    bg: Color(0xFF0B0420),
    surface: Color(0xFF1A0F33),
    primary: Color(0xFFB26CFF),
    secondary: Color(0xFFFF2EC8),
    tertiary: Color(0xFF00E5FF),
    text: Color(0xFFEDE0FF),
    muted: Color(0x66EDE0FF),
    chord: Color(0xFFFF2EC8),
    sectionHeader: Color(0xFF00E5FF),
    sectionHeaderBorder: Color(0xFF00E5FF),
    glowStrength: 1.1,
  );

  static const AppTheme neonGrid = AppTheme(
    id: 'neon_grid',
    name: 'Neon Grid',
    tagline: 'Classic green // S6.5',
    brightness: Brightness.dark,
    bg: Colors.black,
    surface: Color(0xFF1A1A1A),
    primary: Color(0xFF69FFB6),
    secondary: Color(0xFFFF4081),
    tertiary: Color(0xFF00E5FF),
    text: Colors.white,
    muted: Colors.white38,
    chord: Color(0xFF69FFB6),
    sectionHeader: Color(0xFFFF4081),
    sectionHeaderBorder: Color(0xFFFF4081),
    glowStrength: 1.0,
  );

  static const AppTheme miami = AppTheme(
    id: 'miami',
    name: 'Miami',
    tagline: 'Pink + cyan sunset',
    brightness: Brightness.dark,
    bg: Color(0xFF0C1B33),
    surface: Color(0xFF1B2F52),
    primary: Color(0xFFFF5EC4),
    secondary: Color(0xFF3FE0FF),
    tertiary: Color(0xFFFFD166),
    text: Color(0xFFF5F0FF),
    muted: Color(0x80F5F0FF),
    chord: Color(0xFF3FE0FF),
    sectionHeader: Color(0xFFFF5EC4),
    sectionHeaderBorder: Color(0xFFFF5EC4),
    glowStrength: 1.0,
  );

  static const AppTheme outrun = AppTheme(
    id: 'outrun',
    name: 'Outrun',
    tagline: 'Magenta + orange',
    brightness: Brightness.dark,
    bg: Color(0xFF1A0630),
    surface: Color(0xFF2D0A4A),
    primary: Color(0xFFFF3CAC),
    secondary: Color(0xFFFF8A3C),
    tertiary: Color(0xFF784BA0),
    text: Color(0xFFFFF0EA),
    muted: Color(0x88FFF0EA),
    chord: Color(0xFFFF8A3C),
    sectionHeader: Color(0xFFFF3CAC),
    sectionHeaderBorder: Color(0xFFFF3CAC),
    glowStrength: 1.2,
  );

  static const AppTheme tron = AppTheme(
    id: 'tron',
    name: 'Tron',
    tagline: 'Electric blue on black',
    brightness: Brightness.dark,
    bg: Color(0xFF000510),
    surface: Color(0xFF001426),
    primary: Color(0xFF5DF8FF),
    secondary: Color(0xFF0CAFFF),
    tertiary: Color(0xFFFFEE00),
    text: Color(0xFFDFF7FF),
    muted: Color(0x66DFF7FF),
    chord: Color(0xFF5DF8FF),
    sectionHeader: Color(0xFFFFEE00),
    sectionHeaderBorder: Color(0xFFFFEE00),
    glowStrength: 1.4,
  );

  static const AppTheme vaporwave = AppTheme(
    id: 'vaporwave',
    name: 'Vaporwave',
    tagline: 'Pastel dreamstate',
    brightness: Brightness.dark,
    bg: Color(0xFF241446),
    surface: Color(0xFF3A1F66),
    primary: Color(0xFFFFB2E6),
    secondary: Color(0xFFA5F3FF),
    tertiary: Color(0xFFD5BFFF),
    text: Color(0xFFFFF3FC),
    muted: Color(0x88FFF3FC),
    chord: Color(0xFFA5F3FF),
    sectionHeader: Color(0xFFFFB2E6),
    sectionHeaderBorder: Color(0xFFFFB2E6),
    glowStrength: 0.8,
  );

  static const AppTheme hotline = AppTheme(
    id: 'hotline',
    name: 'Hotline',
    tagline: 'Crimson + cyan',
    brightness: Brightness.dark,
    bg: Color(0xFF120303),
    surface: Color(0xFF240909),
    primary: Color(0xFFFF2E4B),
    secondary: Color(0xFF33E5FF),
    tertiary: Color(0xFFFFC857),
    text: Color(0xFFFFE8E0),
    muted: Color(0x77FFE8E0),
    chord: Color(0xFF33E5FF),
    sectionHeader: Color(0xFFFF2E4B),
    sectionHeaderBorder: Color(0xFFFF2E4B),
    glowStrength: 1.3,
  );

  static const AppTheme mandalorian = AppTheme(
    id: 'mandalorian',
    name: 'Mandalorian',
    tagline: 'Beskar silver + crimson',
    brightness: Brightness.dark,
    bg: Color(0xFF0A0A0C),
    surface: Color(0xFF15161A),
    primary: Color(0xFFC9CED6),
    secondary: Color(0xFFB01B2E),
    tertiary: Color(0xFFE3B23C),
    text: Color(0xFFE8EAEE),
    muted: Color(0x66E8EAEE),
    chord: Color(0xFFE3B23C),
    sectionHeader: Color(0xFFB01B2E),
    sectionHeaderBorder: Color(0xFFB01B2E),
    glowStrength: 0.6,
  );

  // ══════════════════════════════════════════════════════
  //  STANDARD THEMES
  // ══════════════════════════════════════════════════════

  static const AppTheme dark = AppTheme(
    id: 'dark',
    name: 'Dark',
    tagline: 'Standard dark',
    brightness: Brightness.dark,
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primary: Color(0xFF82B1FF),
    secondary: Color(0xFFB388FF),
    tertiary: Color(0xFF64FFDA),
    text: Color(0xFFE8E8E8),
    muted: Color(0x80E8E8E8),
    chord: Color(0xFF82B1FF),
    sectionHeader: Color(0xFFB388FF),
    sectionHeaderBorder: Color(0xFFB388FF),
    bodyFont: 'Roboto',
    glowStrength: 0.3,
  );

  static const AppTheme light = AppTheme(
    id: 'light',
    name: 'Light',
    tagline: 'Clean + bright',
    brightness: Brightness.light,
    bg: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF1565C0),
    secondary: Color(0xFFC62828),
    tertiary: Color(0xFF00897B),
    text: Color(0xFF1A1A1A),
    muted: Color(0x991A1A1A),
    chord: Color(0xFF1565C0),
    sectionHeader: Color(0xFFC62828),
    sectionHeaderBorder: Color(0xFFC62828),
    bodyFont: 'Roboto',
    glowStrength: 0.0,
  );

  static const AppTheme paper = AppTheme(
    id: 'paper',
    name: 'Paper',
    tagline: 'Warm sepia // stage daylight',
    brightness: Brightness.light,
    bg: Color(0xFFF5EEDC),
    surface: Color(0xFFFFF8E7),
    primary: Color(0xFF6B4423),
    secondary: Color(0xFFA0522D),
    tertiary: Color(0xFF556B2F),
    text: Color(0xFF3A2718),
    muted: Color(0x993A2718),
    chord: Color(0xFFA0522D),
    sectionHeader: Color(0xFF6B4423),
    sectionHeaderBorder: Color(0xFF6B4423),
    bodyFont: 'serif',
    glowStrength: 0.0,
  );

  static const AppTheme highContrast = AppTheme(
    id: 'high_contrast',
    name: 'High Contrast',
    tagline: 'Accessibility',
    brightness: Brightness.dark,
    bg: Colors.black,
    surface: Color(0xFF0A0A0A),
    primary: Color(0xFFFFFF00),
    secondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF00FF00),
    text: Colors.white,
    muted: Color(0xBBFFFFFF),
    chord: Color(0xFFFFFF00),
    sectionHeader: Color(0xFFFFFFFF),
    sectionHeaderBorder: Color(0xFFFFFFFF),
    glowStrength: 0.0,
  );
}
