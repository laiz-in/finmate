import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum _SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, _SnackType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, _SnackType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, _SnackType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, _SnackType.info);
  }

  static void _show(BuildContext context, String message, _SnackType type) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final (Color bgColor, IconData icon) = switch (type) {
      _SnackType.success => (colors.success, Icons.check_circle_outline),
      _SnackType.error => (colors.error, Icons.error_outline),
      _SnackType.warning => (const Color(0xFFF9A825), Icons.warning_amber_rounded),
      _SnackType.info => (colors.primary, Icons.info_outline),
    };

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: AppTextStyles.bodyMedium(Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}