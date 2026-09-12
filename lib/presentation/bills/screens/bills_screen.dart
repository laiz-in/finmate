import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Bills', style: AppTextStyles.heading3(colors.textPrimary)),
      ),
      body: Center(
        child: Text('No bills added yet', style: AppTextStyles.body(colors.textSecondary)),
      ),
    );
  }
}