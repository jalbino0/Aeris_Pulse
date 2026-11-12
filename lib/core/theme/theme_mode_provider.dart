import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeModeProvider =
    AsyncNotifierProvider<AppThemeModeNotifier, ThemeMode>(
      AppThemeModeNotifier.new,
    );

class AppThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _key = 'aeris_theme_mode';

  @override
  Future<ThemeMode> build() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key);

    return switch (saved) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    final previous = state.asData?.value ?? ThemeMode.light;

    state = AsyncData(mode);

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(_key, mode.name);

      if (!saved) {
        throw StateError('Não foi possível salvar o tema.');
      }
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
