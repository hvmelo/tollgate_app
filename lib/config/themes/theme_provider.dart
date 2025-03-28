import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/local_storage_service.dart';
import '../storage/local_storage_service_provider.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _themePreferenceKey = 'theme_mode';

  late final LocalStorageService _storage;

  @override
  ThemeMode build() {
    _storage = ref.watch(localStorageServiceProvider);
    _loadThemePreference();
    return ThemeMode.system;
  }

  Future<void> _loadThemePreference() async {
    final themeString = _storage.getProperty<String>(_themePreferenceKey);
    if (themeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.saveProperty(_themePreferenceKey, mode.toString());
  }
}
