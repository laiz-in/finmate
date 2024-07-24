import 'package:flutter/material.dart';

class AppColors {
  static const Color myTextBlue = Color.fromARGB(255, 125, 136, 158);
  static const Color myWhite = Color.fromARGB(255, 226, 227, 230);
  static const Color myBlue = Color.fromARGB(57, 11, 15, 27);
  static const Color myOrange = Color.fromARGB(255, 207, 132, 132);
  static const Color myFadeblue = Color.fromARGB(255, 87, 101, 128);
  static const Color myFadeblueEnabled = Color.fromARGB(255, 233, 232, 228);
  static const Color popupInfoBackground = Color.fromARGB(255, 171, 191, 235);
  static const Color popupInfoBlue = Color.fromARGB(255, 74, 103, 233);
  static const Color gradientGreen = Color.fromARGB(57, 6, 119, 76);
  static const Color gradientBlue = Color.fromARGB(255, 7, 37, 65);
  static const Color textFieldColor = Color.fromARGB(255, 20, 27, 32);
  static const Color popupSuccesBackground = Color.fromARGB(255, 214, 241, 212);
  static const Color popupSuccesGreen = Color.fromARGB(255, 58, 121, 17);
  static const Color popupErrorBackground = Color.fromARGB(255, 240, 207, 198);

  static const Color popupErrorRed = Color.fromARGB(255, 182, 81, 95);
  static const Color myGrey = Color.fromARGB(255, 177, 175, 175);
  static const Color myfaded = Color.fromARGB(57, 94, 103, 128);
  static const Color myDark = Color.fromARGB(255, 37, 37, 37);
}


final ThemeData lightTheme = ThemeData(
  cardColor:Color(0xFF4C7766),
primaryColor:Colors.white,
  primaryColorDark: Colors.white,
  scaffoldBackgroundColor: Colors.white,

  // Define other properties for the light theme
);



final ThemeData darkTheme = ThemeData(
  cardColor:Color(0xFF4C7766),
  primaryColorDark: Color.fromARGB(255, 48, 48, 47),

  primaryColor: const Color.fromARGB(255, 34, 34, 34),
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.myWhite),
    bodyMedium: TextStyle(color: AppColors.myWhite),
  ),
  // Define other properties for the dark theme
);
