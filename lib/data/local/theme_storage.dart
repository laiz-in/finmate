import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const String _themeKey = 'isDarkMode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }
}
