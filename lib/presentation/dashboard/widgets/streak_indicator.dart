import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';

/// Counts consecutive days, working backward from today through the 1st of
/// the current month, where total spending stayed at or under the daily
/// budget. Stops (and returns) at the first day the limit was exceeded, or
/// at the start of the month if the streak runs the whole way.
int _currentMonthStreak(List<Expense> expenses, double dailyBudget) {
  if (dailyBudget <= 0) return 0;

  final now = DateTime.now();
  var day = DateTime(now.year, now.month, now.day);
  var streak = 0;

  while (day.month == now.month && day.year == now.year) {
    final spent = expenses
        .where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
        .fold(0.0, (sum, e) => sum + e.amount);

    if (spent <= dailyBudget) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
}

class StreakIndicator extends StatelessWidget {
  final AppColors colors;
  final double dailyBudget;
  final List<Expense> expenses;
  final String firstName;

  const StreakIndicator({
    super.key,
    required this.colors,
    required this.dailyBudget,
    required this.expenses,
    required this.firstName,
  });

  void _showInfo(BuildContext context, int streak) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 17)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Budget streak',
                style: AppTextStyles.button(colors.textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        content: Text(
          'You\'ve stayed within your daily budget for $streak day${streak == 1 ? '' : 's'} in a row this month. '
          'Spend more than your daily limit on any day, and the streak resets ,so keep it up $firstName!',
          style: AppTextStyles.small(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Okay', style: AppTextStyles.bodyMedium(colors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = _currentMonthStreak(expenses, dailyBudget);

    if (streak <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showInfo(context, streak),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '${streak}d streak',
              style: AppTextStyles.small(colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}