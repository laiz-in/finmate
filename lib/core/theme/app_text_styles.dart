import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_font_sizes.dart';
import 'app_font_weights.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    ); 
  }

  static TextStyle display(Color color) => _style(AppFontSizes.display, AppFontWeights.bold, color);
  static TextStyle heading1(Color color) => _style(AppFontSizes.xxl, AppFontWeights.bold, color);
  static TextStyle heading2(Color color) => _style(AppFontSizes.xl, AppFontWeights.semiBold, color);
  static TextStyle heading3(Color color) => _style(AppFontSizes.lg, AppFontWeights.semiBold, color);
  static TextStyle bodyLarge(Color color) => _style(AppFontSizes.md, AppFontWeights.regular, color);
  static TextStyle body(Color color) => _style(AppFontSizes.base, AppFontWeights.regular, color);
  static TextStyle bodyMedium(Color color) => _style(AppFontSizes.base, AppFontWeights.medium, color);
  static TextStyle caption(Color color) => _style(AppFontSizes.sm, AppFontWeights.regular, color);
  static TextStyle small(Color color) => _style(AppFontSizes.xs, AppFontWeights.regular, color);
  static TextStyle button(Color color) => _style(AppFontSizes.base, AppFontWeights.semiBold, color);
}