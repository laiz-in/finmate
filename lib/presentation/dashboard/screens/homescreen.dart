import 'package:finmate/presentation/dashboard/widgets/pixel_spending_chart.dart';
import 'package:finmate/presentation/dashboard/widgets/quick_actions_row.dart';
import 'package:finmate/presentation/dashboard/widgets/safe_to_spend_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_profile.dart';
import '../../expense/bloc/expense_cubit.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/bloc/profile_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;
    final expenseState = context.watch<ExpenseCubit>().state;

    // Show a loading indicator while the profile is being fetched
    if (profile == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [

            // HEADER
            _Header(colors: colors, profile: profile),
            const SizedBox(height: 18),

            //DATE LABEL
            _DateLabel(colors: colors),
            const SizedBox(height: 10),

            // MAIN SAFE TO SPEND CARD
            SafeToSpendCard(
              colors: colors,
              symbol: profile.currencySymbol,
              dailyBudget: profile.dailyBudget,
              monthlyBudget: profile.monthlyBudget,
              expenses: expenseState.expenses,
            ),
            const SizedBox(height: 28),
            QuickActionsRow(colors: colors),
            const SizedBox(height: 28),

            //PIXEL LIKE SPENDING CHART
            PixelSpendingChart(
              colors: colors,
              expenses: expenseState.expenses,
              symbol: profile.currencySymbol,
            ),
            const SizedBox(height: 28),




          ],
        ),
      ),
    );
  }
}

// ---------------- Date / time helpers ----------------

const _weekdaysFull = [
  'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
];
const _monthsFull = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
];

// Helper function to get the current date in the format "WEEKDAY, DAY MONTH"
String _formattedDate() {
  final now = DateTime.now();
  final weekday = _weekdaysFull[now.weekday - 1];
  final month = _monthsFull[now.month - 1];
  return '$weekday, ${now.day} $month';
}


// ---------------- Header section ( welcome text and notifications ) ----------------

class _Header extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _Header({required this.colors, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.heading3(colors.primary),
              children: [
                TextSpan(
                  text: 'Hello ',
                  style: TextStyle(color: colors.primary.withValues(alpha: 0.6)),
                ),
                TextSpan(text: profile.firstName),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.notifications_none_rounded, color: colors.textPrimary, size: 20),
          ),
        ),
      ],
    );
  }
}

// ---------------- Date label (sits above the Safe to Spend card) ----------------

class _DateLabel extends StatelessWidget {
  final AppColors colors;
  const _DateLabel({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedDate(),
      style: AppTextStyles.small(colors.textSecondary),
    );
  }
}
