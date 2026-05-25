import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/ui/theme.dart';
import 'package:open_praise/ui/themes/theme_presets.dart';

void main() {
  group('AppThemes registry', () {
    test('default theme is synthwave84', () {
      expect(AppThemes.defaultTheme.id, 'synthwave_84');
    });

    test('all presets have unique ids', () {
      final ids = AppThemes.all.map((t) => t.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('byId falls back to default when id is unknown', () {
      final unknown = AppThemes.byId('does_not_exist');
      expect(unknown.id, equals(AppThemes.defaultTheme.id));
    });

    test('themes are grouped by category', () {
      final groups = AppThemes.grouped;
      expect(groups.length, equals(AppThemes.categories.length));

      // All themes should be in exactly one group
      final flat = groups.expand((g) => g).toList();
      expect(flat.length, equals(AppThemes.all.length));
    });

    test('includes synthwave, standard, and special categories', () {
      final ids = AppThemes.all.map((t) => t.id).toSet();
      expect(AppThemes.categories, containsAll(['Synthwave', 'Standard', 'Special']));

      // Synthwave themes
      expect(ids, containsAll([
        'synthwave_84', 'purple_synthwave', 'neon_grid', 'miami', 'outrun',
        'tron', 'vaporwave', 'hotline',
      ]));

      // Standard themes
      expect(ids, containsAll([
        'dark', 'dark_neutral', 'light', 'paper', 'nord', 'solarized_light', 'dracula',
      ]));

      // Special themes
      expect(ids, containsAll([
        'mandalorian', 'high_contrast', 'cyberpunk', 'aurora',
        'retro_terminal', 'ocean', 'royal', 'tokyo_night', 'monokai',
      ]));
    });
  });

  group('AppTheme.toThemeData', () {
    test('installs the theme as a ThemeExtension', () {
      final data = AppThemes.synthwave84.toThemeData();
      final ext = data.extension<AppTheme>();
      expect(ext, isNotNull);
      expect(ext!.id, 'synthwave_84');
    });

    test('ColorScheme brightness matches the preset', () {
      expect(AppThemes.light.toThemeData().brightness, Brightness.light);
      expect(AppThemes.dark.toThemeData().brightness, Brightness.dark);
    });

    test('all themes produce valid ThemeData without crashing', () {
      for (final theme in AppThemes.all) {
        expect(theme.toThemeData().extension<AppTheme>(), isNotNull,
            reason: '${theme.id} should produce valid ThemeData');
      }
    });

    test('themes have unique color identities', () {
      // Ensure no two themes have identical bg + primary combos
      for (var i = 0; i < AppThemes.all.length; i++) {
        for (var j = i + 1; j < AppThemes.all.length; j++) {
          final a = AppThemes.all[i];
          final b = AppThemes.all[j];
          final sameBg = a.bg == b.bg;
          final samePrimary = a.primary == b.primary;
          expect(sameBg && samePrimary, isFalse,
              reason: '${a.id} and ${b.id} have the same bg and primary');
        }
      }
    });
  });
}
