import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/ui/theme.dart';
import 'package:open_praise/ui/themes/theme_presets.dart';

void main() {
  group('AppThemes registry', () {
    test('default theme is purple synthwave', () {
      expect(AppThemes.defaultTheme.id, 'purple_synthwave');
    });

    test('all presets have unique ids', () {
      final ids = AppThemes.all.map((t) => t.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('byId falls back to default when id is unknown', () {
      final unknown = AppThemes.byId('does_not_exist');
      expect(unknown.id, equals(AppThemes.defaultTheme.id));
    });

    test('includes both standard and synthwave variants', () {
      final ids = AppThemes.all.map((t) => t.id).toSet();
      // Synthwave variants
      expect(ids, containsAll([
        'purple_synthwave', 'neon_grid', 'miami', 'outrun',
        'tron', 'vaporwave', 'hotline', 'mandalorian',
      ]));
      // Standard themes
      expect(ids, containsAll([
        'light', 'dark', 'paper', 'high_contrast',
      ]));
    });
  });

  group('AppTheme.toThemeData', () {
    test('installs the theme as a ThemeExtension', () {
      final data = AppThemes.purpleSynthwave.toThemeData();
      final ext = data.extension<AppTheme>();
      expect(ext, isNotNull);
      expect(ext!.id, 'purple_synthwave');
    });

    test('ColorScheme brightness matches the preset', () {
      expect(AppThemes.light.toThemeData().brightness, Brightness.light);
      expect(AppThemes.dark.toThemeData().brightness, Brightness.dark);
    });
  });
}
