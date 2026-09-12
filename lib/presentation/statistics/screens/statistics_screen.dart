import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Statistics', style: AppTextStyles.heading3(colors.textPrimary)),
      ),
      body: Center(
        child: Text('Statistics coming soon', style: AppTextStyles.body(colors.textSecondary)),
      ),
    );
  }
}