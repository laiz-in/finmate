import 'package:flutter/material.dart';

/// A page route that matches the app's own background during transition,
/// preventing the default white flash Flutter's MaterialPageRoute can show
/// for a frame before the destination screen's own Scaffold paints.
Route<T> appPageRoute<T>(Widget page, Color backgroundColor) {
  return PageRouteBuilder<T>(
    opaque: true,
    barrierColor: backgroundColor,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: Container(color: backgroundColor, child: child),
      );
    },
  );
}