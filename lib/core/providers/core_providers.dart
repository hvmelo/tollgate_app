import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

part 'core_providers.g.dart';

/// Theme mode provider for app-wide theme control
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _themePreferenceKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemePreference();
    return ThemeMode.system;
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePreferenceKey);

    if (themeString != null) {
      final themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
      state = themeMode;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, mode.toString());
  }
}

@Riverpod(keepAlive: true)
SharedPreferences? sharedPreferences(Ref ref) {
  return null;
}

@Riverpod(keepAlive: true)
AppEnvironment environment(Ref ref) {
  return AppConfig.environment;
}
