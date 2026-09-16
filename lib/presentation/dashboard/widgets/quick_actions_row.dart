import 'package:finmate/core/utils/app_page_route.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bills/screens/bills_screen.dart';
import '../../income/screens/income_screen.dart';
import '../../liabilities/screens/liabilities_screen.dart';
import '../../statistics/screens/statistics_screen.dart';

class QuickActionsRow extends StatelessWidget {
  final AppColors colors;
  const QuickActionsRow({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        icon: Iconsax.wallet_3,
        label: 'LIABILITIES',
        builder: (_) => const LiabilitiesScreen(),
      ),
      _ActionData(
        icon: Iconsax.receipt_1,
        label: 'BILLS',
        builder: (_) => const BillsScreen(),
      ),
      _ActionData(
        icon: Iconsax.status_up,
        label: 'STATISTICS',
        builder: (_) => const StatisticsScreen(),
      ),
      _ActionData(
        icon: Iconsax.received,
        label: 'INCOME',
        builder: (_) => const IncomeScreen(),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return _ActionButton(
          colors: colors,
          icon: action.icon,
          label: action.label,
              onTap: () {
                Navigator.of(context).push(
                  appPageRoute(action.builder(context), colors.background),
                );
              },
        );
      }).toList(),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;
  const _ActionData({required this.icon, required this.label, required this.builder});
}

class _ActionButton extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.colors,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border),
            ),
            child: Icon(icon, color: colors.primary, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.small(colors.textSecondary),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}