import 'package:flutter/material.dart';
import '../theme.dart';

/// All shipped themes, in the order they appear in the picker.
class AppThemes {
  AppThemes._();

  /// All theme presets, grouped by category.
  static const List<AppTheme> all = [
    // ── Synthwave ──────────────────────────────────────
    purpleSynthwave,
    synthwave84,
    neonGrid,
    miami,
    outrun,
    tron,
    vaporwave,
    hotline,
    // ── Standard ────────────────────────────────────────
    dark,
    darkNeutral,
    light,
    paper,
    nord,
    solarizedLight,
    dracula,
    // ── Special ─────────────────────────────────────────
    mandalorian,
    highContrast,
    cyberpunk,
    aurora,
    retroTerminal,
    ocean,
    royal,
    tokyoNight,
    monokai,
  ];

  /// All unique category labels, in display order.
  static const List<String> categories = [
    'Synthwave',
    'Standard',
    'Special',
  ];

  /// Themes grouped by category.
  static List<List<AppTheme>> get grouped {
    return categories.map((cat) {
      return all.where((t) => t.category == cat).toList();
    }).toList();
  }

  static AppTheme byId(String id) => all.firstWhere(
        (t) => t.id == id,
        orElse: () => defaultTheme,
      );

  static const AppTheme defaultTheme = synthwave84;

  // ══════════════════════════════════════════════════════
  //  S Y N T H W A V E
  // ══════════════════════════════════════════════════════

  /// The classic default — Deep purple, neon pink, cyan accents.
  static const AppTheme purpleSynthwave = AppTheme(
    id: 'purple_synthwave',
    name: 'Purple Synthwave',
    tagline: 'The Wave // Default',
    category: 'Synthwave',
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

  /// Synthwave '84 — Matches the Omarchy synthwave84 desktop theme.
  /// Deep purple-black background, purple primary, hot pink accents,
  /// and yellow tertiary for that retro-futurist display glow.
  static const AppTheme synthwave84 = AppTheme(
    id: 'synthwave_84',
    name: 'Synthwave \'84',
    tagline: 'Deep purple // Omarchy',
    category: 'Synthwave',
    brightness: Brightness.dark,
    bg: Color(0xFF0D0221),
    surface: Color(0xFF240037),
    primary: Color(0xFF8F00FF),
    secondary: Color(0xFFFF00FF),
    tertiary: Color(0xFFF3E70F),
    text: Color(0xFFFFFFFF),
    muted: Color(0x80FFFFFF),
    chord: Color(0xFFFF00FF),
    sectionHeader: Color(0xFFF3E70F),
    sectionHeaderBorder: Color(0xFFF3E70F),
    glowStrength: 1.3,
  );

  /// Classic green-on-black grid aesthetic.
  static const AppTheme neonGrid = AppTheme(
    id: 'neon_grid',
    name: 'Neon Grid',
    tagline: 'Classic green // S6.5',
    category: 'Synthwave',
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

  /// Pink + cyan Miami sunset vibes.
  static const AppTheme miami = AppTheme(
    id: 'miami',
    name: 'Miami',
    tagline: 'Pink + cyan sunset',
    category: 'Synthwave',
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

  /// Magenta + orange Outrun aesthetic.
  static const AppTheme outrun = AppTheme(
    id: 'outrun',
    name: 'Outrun',
    tagline: 'Magenta + orange',
    category: 'Synthwave',
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

  /// Electric blue on black — Tron Legacy inspired.
  static const AppTheme tron = AppTheme(
    id: 'tron',
    name: 'Tron',
    tagline: 'Electric blue on black',
    category: 'Synthwave',
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

  /// Pastel dreamstate — soft pinks, lavenders, mint.
  static const AppTheme vaporwave = AppTheme(
    id: 'vaporwave',
    name: 'Vaporwave',
    tagline: 'Pastel dreamstate',
    category: 'Synthwave',
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

  /// Crimson + cyan — intense, stage-ready contrast.
  static const AppTheme hotline = AppTheme(
    id: 'hotline',
    name: 'Hotline',
    tagline: 'Crimson + cyan',
    category: 'Synthwave',
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

  // ══════════════════════════════════════════════════════
  //  S T A N D A R D
  // ══════════════════════════════════════════════════════

  /// Clean, modern dark theme with blue-purple accents.
  static const AppTheme dark = AppTheme(
    id: 'dark',
    name: 'Dark',
    tagline: 'Modern dark',
    category: 'Standard',
    brightness: Brightness.dark,
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E2E),
    primary: Color(0xFF7C9FFF),
    secondary: Color(0xFFBB86FC),
    tertiary: Color(0xFF64FFDA),
    text: Color(0xFFE8E8EE),
    muted: Color(0x80E8E8EE),
    chord: Color(0xFF7C9FFF),
    sectionHeader: Color(0xFFBB86FC),
    sectionHeaderBorder: Color(0xFFBB86FC),
    bodyFont: 'Roboto',
    glowStrength: 0.3,
  );

  /// Warm neutral dark — easy on the eyes for long rehearsals.
  static const AppTheme darkNeutral = AppTheme(
    id: 'dark_neutral',
    name: 'Dark Neutral',
    tagline: 'Warm dark gray',
    category: 'Standard',
    brightness: Brightness.dark,
    bg: Color(0xFF181818),
    surface: Color(0xFF242424),
    primary: Color(0xFFE0A96D),
    secondary: Color(0xFF7EB8DA),
    tertiary: Color(0xFFA8D87C),
    text: Color(0xFFE0E0E0),
    muted: Color(0x80E0E0E0),
    chord: Color(0xFFE0A96D),
    sectionHeader: Color(0xFF7EB8DA),
    sectionHeaderBorder: Color(0xFF7EB8DA),
    bodyFont: 'Roboto',
    glowStrength: 0.2,
  );

  /// Clean, bright light theme.
  static const AppTheme light = AppTheme(
    id: 'light',
    name: 'Light',
    tagline: 'Clean + bright',
    category: 'Standard',
    brightness: Brightness.light,
    bg: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF1A73E8),
    secondary: Color(0xFFD93025),
    tertiary: Color(0xFF00897B),
    text: Color(0xFF1F1F1F),
    muted: Color(0x991F1F1F),
    chord: Color(0xFF1A73E8),
    sectionHeader: Color(0xFFD93025),
    sectionHeaderBorder: Color(0xFFD93025),
    bodyFont: 'Roboto',
    glowStrength: 0.0,
  );

  /// Warm sepia paper — designed for stage daylight readability.
  static const AppTheme paper = AppTheme(
    id: 'paper',
    name: 'Paper',
    tagline: 'Warm sepia // stage daylight',
    category: 'Standard',
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

  /// Arctic-inspired blue-gray palette. Calm, focused.
  static const AppTheme nord = AppTheme(
    id: 'nord',
    name: 'Nord',
    tagline: 'Arctic blue-gray',
    category: 'Standard',
    brightness: Brightness.dark,
    bg: Color(0xFF2E3440),
    surface: Color(0xFF3B4252),
    primary: Color(0xFF88C0D0),
    secondary: Color(0xFFBF616A),
    tertiary: Color(0xFFA3BE8C),
    text: Color(0xFFECEFF4),
    muted: Color(0x80ECEFF4),
    chord: Color(0xFF88C0D0),
    sectionHeader: Color(0xFFBF616A),
    sectionHeaderBorder: Color(0xFFBF616A),
    bodyFont: 'Roboto',
    glowStrength: 0.2,
  );

  /// Solarized Light — warm, low-contrast, scientifically tuned.
  static const AppTheme solarizedLight = AppTheme(
    id: 'solarized_light',
    name: 'Solarized Light',
    tagline: 'Warm low-contrast',
    category: 'Standard',
    brightness: Brightness.light,
    bg: Color(0xFFFDF6E3),
    surface: Color(0xFFEEE8D5),
    primary: Color(0xFF268BD2),
    secondary: Color(0xFFDC322F),
    tertiary: Color(0xFF859900),
    text: Color(0xFF657B83),
    muted: Color(0x80657B83),
    chord: Color(0xFF268BD2),
    sectionHeader: Color(0xFFDC322F),
    sectionHeaderBorder: Color(0xFFDC322F),
    bodyFont: 'Roboto',
    glowStrength: 0.0,
  );

  /// Dracula — dark purple with vibrant accent colors.
  static const AppTheme dracula = AppTheme(
    id: 'dracula',
    name: 'Dracula',
    tagline: 'Dark purple + vibrant',
    category: 'Standard',
    brightness: Brightness.dark,
    bg: Color(0xFF282A36),
    surface: Color(0xFF44475A),
    primary: Color(0xFFBD93F9),
    secondary: Color(0xFFFF79C6),
    tertiary: Color(0xFF50FA7B),
    text: Color(0xFFF8F8F2),
    muted: Color(0x80F8F8F2),
    chord: Color(0xFFBD93F9),
    sectionHeader: Color(0xFFFF79C6),
    sectionHeaderBorder: Color(0xFFFF79C6),
    bodyFont: 'Roboto',
    glowStrength: 0.4,
  );

  // ══════════════════════════════════════════════════════
  //  S P E C I A L
  // ══════════════════════════════════════════════════════

  /// Beskar silver + crimson — Mandalorian inspired.
  static const AppTheme mandalorian = AppTheme(
    id: 'mandalorian',
    name: 'Mandalorian',
    tagline: 'Beskar silver + crimson',
    category: 'Special',
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

  /// Maximum contrast for accessibility.
  static const AppTheme highContrast = AppTheme(
    id: 'high_contrast',
    name: 'High Contrast',
    tagline: 'Accessibility',
    category: 'Special',
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

  /// Neon yellow and cyan on deep navy — a cyberdeck vibe.
  static const AppTheme cyberpunk = AppTheme(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    tagline: 'Yellow + cyan // decked',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF0B0E2A),
    surface: Color(0xFF141838),
    primary: Color(0xFFFFF44F),
    secondary: Color(0xFF00E5FF),
    tertiary: Color(0xFFFF2D78),
    text: Color(0xFFE8E8F0),
    muted: Color(0x80E8E8F0),
    chord: Color(0xFFFFF44F),
    sectionHeader: Color(0xFF00E5FF),
    sectionHeaderBorder: Color(0xFF00E5FF),
    glowStrength: 1.5,
  );

  /// Green ↔ blue ↔ purple polar light gradient feel.
  static const AppTheme aurora = AppTheme(
    id: 'aurora',
    name: 'Aurora',
    tagline: 'Polar light gradient',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF0A1628),
    surface: Color(0xFF112240),
    primary: Color(0xFF64FFDA),
    secondary: Color(0xFF80BFFF),
    tertiary: Color(0xFFC792EA),
    text: Color(0xFFCCD6F6),
    muted: Color(0x80CCD6F6),
    chord: Color(0xFF64FFDA),
    sectionHeader: Color(0xFFC792EA),
    sectionHeaderBorder: Color(0xFFC792EA),
    glowStrength: 0.7,
  );

  /// Classic amber/retro green on black — CRT terminal vibes.
  static const AppTheme retroTerminal = AppTheme(
    id: 'retro_terminal',
    name: 'Retro Terminal',
    tagline: 'Green phosphor // CRT',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    primary: Color(0xFF33FF33),
    secondary: Color(0xFF00CC00),
    tertiary: Color(0xFFFFAA00),
    text: Color(0xFFB3FFB3),
    muted: Color(0x66B3FFB3),
    chord: Color(0xFF33FF33),
    sectionHeader: Color(0xFFFFAA00),
    sectionHeaderBorder: Color(0xFFFFAA00),
    glowStrength: 0.5,
  );

  /// Deep teal and ocean blue — calm, submerged.
  static const AppTheme ocean = AppTheme(
    id: 'ocean',
    name: 'Ocean',
    tagline: 'Deep teal + blue',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF051F2E),
    surface: Color(0xFF0B3348),
    primary: Color(0xFF4FD1C5),
    secondary: Color(0xFF63B3ED),
    tertiary: Color(0xFFF6AD55),
    text: Color(0xFFE2E8F0),
    muted: Color(0x80E2E8F0),
    chord: Color(0xFF4FD1C5),
    sectionHeader: Color(0xFFF6AD55),
    sectionHeaderBorder: Color(0xFFF6AD55),
    glowStrength: 0.5,
  );

  /// Opulent deep purple with gold accents.
  static const AppTheme royal = AppTheme(
    id: 'royal',
    name: 'Royal',
    tagline: 'Purple + gold',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF1A0A2E),
    surface: Color(0xFF2D1B4E),
    primary: Color(0xFFD4AF37),
    secondary: Color(0xFF9B59B6),
    tertiary: Color(0xFFE74C3C),
    text: Color(0xFFF5F0FF),
    muted: Color(0x80F5F0FF),
    chord: Color(0xFFD4AF37),
    sectionHeader: Color(0xFF9B59B6),
    sectionHeaderBorder: Color(0xFF9B59B6),
    glowStrength: 0.8,
  );

  /// Tokyo Night — popular deep blue-dark theme.
  static const AppTheme tokyoNight = AppTheme(
    id: 'tokyo_night',
    name: 'Tokyo Night',
    tagline: 'Deep blue // storm',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF1A1B26),
    surface: Color(0xFF24283B),
    primary: Color(0xFF7AA2F7),
    secondary: Color(0xFFBB9AF7),
    tertiary: Color(0xFF9ECE6A),
    text: Color(0xFFA9B1D6),
    muted: Color(0x80A9B1D6),
    chord: Color(0xFF7AA2F7),
    sectionHeader: Color(0xFFBB9AF7),
    sectionHeaderBorder: Color(0xFFBB9AF7),
    bodyFont: 'Roboto',
    glowStrength: 0.3,
  );

  /// Monokai-inspired — vibrant dark with saturated accents.
  static const AppTheme monokai = AppTheme(
    id: 'monokai',
    name: 'Monokai',
    tagline: 'Saturated dark',
    category: 'Special',
    brightness: Brightness.dark,
    bg: Color(0xFF272822),
    surface: Color(0xFF383830),
    primary: Color(0xFFA6E22E),
    secondary: Color(0xFFFD971F),
    tertiary: Color(0xFFE6DB74),
    text: Color(0xFFF8F8F2),
    muted: Color(0x80F8F8F2),
    chord: Color(0xFFA6E22E),
    sectionHeader: Color(0xFFFD971F),
    sectionHeaderBorder: Color(0xFFFD971F),
    bodyFont: 'Roboto',
    glowStrength: 0.4,
  );
}
