import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive_store.dart';
import '../ui/theme.dart';
import '../ui/themes/theme_presets.dart';

const String _themeSettingKey = 'active_theme_id';

class ThemeController extends StateNotifier<AppTheme> {
  ThemeController() : super(_loadInitial());

  static AppTheme _loadInitial() {
    final id = HiveStore.getSetting<String>(_themeSettingKey);
    return id == null ? AppThemes.defaultTheme : AppThemes.byId(id);
  }

  Future<void> setTheme(String id) async {
    final next = AppThemes.byId(id);
    state = next;
    await HiveStore.setSetting(_themeSettingKey, next.id);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeController, AppTheme>((ref) => ThemeController());
