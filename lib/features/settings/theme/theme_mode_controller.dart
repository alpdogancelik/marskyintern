import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const String _boxName = 'prefs';
  static const String _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    _restoreThemeMode();
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final box = await _openPrefsBox();
    await box.put(_themeModeKey, _encode(mode));
  }

  Future<void> setDarkModeEnabled(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _restoreThemeMode() async {
    final box = await _openPrefsBox();
    final raw = box.get(_themeModeKey);
    final restored = _decode(raw?.toString());
    if (restored == null) {
      return;
    }
    try {
      state = restored;
    } catch (_) {
      // Ignore late async restore if provider was disposed.
    }
  }

  Future<Box<dynamic>> _openPrefsBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  String _encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  ThemeMode? _decode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}
