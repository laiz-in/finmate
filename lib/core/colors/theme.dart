import 'package:flutter/material.dart';
import 'package:moneyy/core/colors/colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.foregroundColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: const Color.fromARGB(255, 230, 229, 227),
    canvasColor: AppColors.foregroundColor,
    hintColor: AppColors.backgroundColor,
    primaryColorDark: AppColors.foregroundColor,
    highlightColor: const Color.fromARGB(255, 196, 194, 194),
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColors.darkBackgroundColor,
    hintColor: AppColors.darkBackgroundColor,
    cardColor: Color.fromARGB(255, 176, 175, 177),
    canvasColor: Colors.white.withOpacity(0.7),
    primaryColorDark:Color.fromARGB(255, 176, 175, 177),
    highlightColor: AppColors.darkBackgroundColor,
    // Add more dark theme customizations
  );
}
