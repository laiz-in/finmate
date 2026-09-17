import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../shared_widgets/confirmation_dialog.dart';

Future<bool> showSignOutDialog(BuildContext context, AppColors colors) {
  return showConfirmationDialog(
    context: context,
    colors: colors,
    title: 'Sign out?',
    message: "You'll need to sign in again to access your expenses and budgets.",
    confirmLabel: 'Sign out',
    confirmColor: colors.error,
  );
}