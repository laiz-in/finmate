import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _boxName = 'settingsBox';
  static const _key = 'themeMode';

  ThemeCubit() : super(_loadInitial());

  static ThemeMode _loadInitial() {
    final box = Hive.box(_boxName);
    final saved = box.get(_key, defaultValue: 'system') as String;
    return _fromString(saved);
  }

  void toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _setTheme(next);
  }

  void setTheme(ThemeMode mode) => _setTheme(mode);

  void _setTheme(ThemeMode mode) {
    final box = Hive.box(_boxName);
    box.put(_key, _toString(mode));
    emit(mode);
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}