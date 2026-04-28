import 'package:flutter/material.dart';

/// Palette + style bundle for a single theme preset.
///
/// Registered as a [ThemeExtension] so any widget can read it via
/// `AppTheme.of(context)` without needing Riverpod access.
class AppTheme extends ThemeExtension<AppTheme> {
  final String id;
  final String name;
  final String tagline;
  final Brightness brightness;

  // Core palette
  final Color bg;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color text;
  final Color muted;

  // Chord-sheet specific
  final Color chord;
  final Color sectionHeader;
  final Color sectionHeaderBorder;

  // Typography
  final String bodyFont;
  final String monoFont;
  final double glowStrength;

  const AppTheme({
    required this.id,
    required this.name,
    required this.tagline,
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.text,
    required this.muted,
    required this.chord,
    required this.sectionHeader,
    required this.sectionHeaderBorder,
    this.bodyFont = 'monospace',
    this.monoFont = 'monospace',
    this.glowStrength = 1.0,
  });

  static AppTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTheme>()!;

  // ── Reusable text styles ──────────────────────────────
  TextStyle get mono =>
      TextStyle(fontFamily: monoFont, color: primary);

  TextStyle get heading => TextStyle(
        fontFamily: monoFont,
        color: primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      );

  TextStyle get body =>
      TextStyle(fontFamily: bodyFont, color: text, fontSize: 14);

  // ── Reusable decorations/buttons ──────────────────────
  BoxDecoration neonBorder([Color? color]) {
    final c = color ?? primary;
    return BoxDecoration(
      border: Border.all(color: c.withValues(alpha: 0.6)),
      borderRadius: BorderRadius.circular(8),
      color: surface,
      boxShadow: [
        BoxShadow(color: c.withValues(alpha: 0.15 * glowStrength), blurRadius: 8),
      ],
    );
  }

  ButtonStyle neonButton([Color? color]) {
    final c = color ?? primary;
    return OutlinedButton.styleFrom(
      foregroundColor: c,
      side: BorderSide(color: c),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  /// App bar with the signature glow underline.
  AppBar appBar(String title, {List<Widget>? actions}) => AppBar(
        title: Text(title, style: heading.copyWith(fontSize: 16)),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: primary,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: glowStrength),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );

  /// Materialize this palette into a full [ThemeData] for [MaterialApp].
  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: bg,
        secondary: secondary,
        onSecondary: bg,
        tertiary: tertiary,
        onTertiary: bg,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surface,
        onSurface: text,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: primary, fontFamily: monoFont),
        bodyMedium: TextStyle(color: text, fontFamily: bodyFont),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
      ),
      extensions: [this],
    );
  }

  @override
  AppTheme copyWith({
    String? id,
    String? name,
    String? tagline,
    Brightness? brightness,
    Color? bg,
    Color? surface,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? text,
    Color? muted,
    Color? chord,
    Color? sectionHeader,
    Color? sectionHeaderBorder,
    String? bodyFont,
    String? monoFont,
    double? glowStrength,
  }) =>
      AppTheme(
        id: id ?? this.id,
        name: name ?? this.name,
        tagline: tagline ?? this.tagline,
        brightness: brightness ?? this.brightness,
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        tertiary: tertiary ?? this.tertiary,
        text: text ?? this.text,
        muted: muted ?? this.muted,
        chord: chord ?? this.chord,
        sectionHeader: sectionHeader ?? this.sectionHeader,
        sectionHeaderBorder: sectionHeaderBorder ?? this.sectionHeaderBorder,
        bodyFont: bodyFont ?? this.bodyFont,
        monoFont: monoFont ?? this.monoFont,
        glowStrength: glowStrength ?? this.glowStrength,
      );

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    // Swap instantly past the midpoint — themes aren't meant to cross-fade.
    return t < 0.5 ? this : other;
  }
}
