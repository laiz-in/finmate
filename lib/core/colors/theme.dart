import 'package:flutter/material.dart';
import 'package:moneyy/core/colors/colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.backgroundColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: const Color.fromARGB(255, 230, 229, 227),
    canvasColor: AppColors.foregroundColor,
    hintColor: AppColors.backgroundColor,
    primaryColorDark: AppColors.foregroundColor,
    highlightColor: Color.fromARGB(255, 210, 216, 214),
  );

  static final darkTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 22, 22, 22),
    scaffoldBackgroundColor: Colors.black,
    cardColor: Color.fromARGB(255, 56, 56, 56),
    canvasColor: Colors.white.withOpacity(0.7),
    hintColor: AppColors.darkBackgroundColor,
    primaryColorDark:Color.fromARGB(255, 176, 175, 177),
    highlightColor: AppColors.darkBackgroundColor,
    // Add more dark theme customizations
  );
}
