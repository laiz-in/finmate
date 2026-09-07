import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/user_profile.dart';
import '../../expense/bloc/expense_cubit.dart';
import '../../profile/bloc/profile_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;
    final expenseState = context.watch<ExpenseCubit>().state;

    if (profile == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _Header(colors: colors, profile: profile),
            const SizedBox(height: 28),
            _DateLabel(colors: colors),
            const SizedBox(height: 10),
            _SafeToSpendCard(colors: colors, profile: profile, expenses: expenseState.expenses),
            const SizedBox(height: 28),
          
          ],
        ),
      ),
    );
  }
}

// ---------------- Date / time helpers ----------------

const _weekdaysFull = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];



/// e.g. "Wednesday, 26 August" — natural case, not all-caps.
String _formattedDate() {
  final now = DateTime.now();
  final weekday = _weekdaysFull[now.weekday - 1];
  final month = _monthsFull[now.month - 1];
  return '$weekday, ${now.day} $month';
}

int _daysInCurrentMonth() {
  final now = DateTime.now();
  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final lastDay = nextMonth.subtract(const Duration(days: 1));
  return lastDay.day;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

double _sumToday(List<Expense> expenses) {
  final now = DateTime.now();
  return expenses.where((e) => _isSameDay(e.date, now)).fold(0.0, (sum, e) => sum + e.amount);
}

/// Sum of every expense from the 1st of the current month through today.
/// _isSameMonth only checks year/month, so this naturally covers the whole
/// month-to-date regardless of which day it is.
double _sumThisMonth(List<Expense> expenses) {
  final now = DateTime.now();
  return expenses.where((e) => _isSameMonth(e.date, now)).fold(0.0, (sum, e) => sum + e.amount);
}

// ---------------- Header ----------------

class _Header extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _Header({required this.colors, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hey, ${profile.firstName}',
      style: AppTextStyles.heading2(colors.primary),
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
      style: AppTextStyles.bodyMedium(colors.textSecondary),
    );
  }
}

// ---------------- Safe to spend card ----------------

class _SafeToSpendCard extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  final List<Expense> expenses;
  const _SafeToSpendCard({required this.colors, required this.profile, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final symbol = profile.currencySymbol;
    final dailyBudget = profile.dailyBudget;
    final monthlyBudget = profile.monthlyBudget;

    final spentToday = _sumToday(expenses);
    final spentThisMonth = _sumThisMonth(expenses);

    final dailyProgress = dailyBudget > 0 ? (spentToday / dailyBudget).clamp(0.0, 1.0) : 0.0;
    final monthlyProgress = monthlyBudget > 0 ? (spentThisMonth / monthlyBudget).clamp(0.0, 1.0) : 0.0;

    final dailyOver = spentToday > dailyBudget;
    final monthlyOver = spentThisMonth > monthlyBudget;
    final now = DateTime.now();
    final month = _monthsFull[now.month - 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, Colors.black, 0.25)!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SpendStat(
            spent: spentToday,
            limit: dailyBudget,
            symbol: symbol,
            progress: dailyProgress,
            isOver: dailyOver,
            suffix: 'spent today',
          ),
          const SizedBox(height: 22),
          _SpendStat(
            spent: spentThisMonth,
            limit: monthlyBudget,
            symbol: symbol,
            progress: monthlyProgress,
            isOver: monthlyOver,
            suffix: '',
          ),
        ],
      ),
    );
  }
}

class _SpendStat extends StatelessWidget {
  final double spent;
  final double limit;
  final String symbol;
  final double progress;
  final bool isOver;
  final String suffix;

  const _SpendStat({
    required this.spent,
    required this.limit,
    required this.symbol,
    required this.progress,
    required this.isOver,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final spentColor = isOver ? const Color(0xFFFFCDD2) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                '$symbol${spent.toStringAsFixed(0)}',
                style: AppTextStyles.heading2(spentColor),
              ),
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                '/${limit.toStringAsFixed(0)} $suffix',
                style: AppTextStyles.body(Colors.white.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: AlwaysStoppedAnimation<Color>(isOver ? const Color(0xFFFFCDD2) : Colors.white),
          ),
        ),
      ],
    );
  }
}



