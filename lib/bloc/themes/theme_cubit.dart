import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:moneyy/data/local/theme_storage.dart'; // Your local storage file

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeStorage themeStorage;

  ThemeCubit(this.themeStorage) : super(ThemeMode.light);

  Future<void> loadTheme() async {
    final isDarkMode = await themeStorage.isDarkMode();
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(newTheme);
    themeStorage.saveThemeMode(newTheme);
  }
}
