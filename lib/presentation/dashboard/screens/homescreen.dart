import 'package:finmate/presentation/dashboard/screens/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';
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
            const SizedBox(height: 18),
            _DateLabel(colors: colors),
            const SizedBox(height: 10),
            _SafeToSpendCard(colors: colors, profile: profile, expenses: expenseState.expenses),
            const SizedBox(height: 28),
            SpendingChart(
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
      style: AppTextStyles.caption(colors.textSecondary),
    );
  }
}

// ---------------- Safe to spend card (animated flip: Today <-> This Month) ----------------

class _SafeToSpendCard extends StatefulWidget {
  final AppColors colors;
  final UserProfile profile;
  final List<Expense> expenses;
  const _SafeToSpendCard({required this.colors, required this.profile, required this.expenses});

  @override
  State<_SafeToSpendCard> createState() => _SafeToSpendCardState();
}

class _SafeToSpendCardState extends State<_SafeToSpendCard> {
  bool _isTodayFront = true;

  static const double _frontHeight = 148;
  static const double _backHeight = 102;
  static const double _backOverlap = 20;
  static const Duration _duration = Duration(milliseconds: 380);
  static const Curve _curve = Curves.easeOutCubic;

  void _flip() => setState(() => _isTodayFront = !_isTodayFront);

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final profile = widget.profile;
    final expenses = widget.expenses;

    final symbol = profile.currencySymbol;
    final dailyBudget = profile.dailyBudget;
    final monthlyBudget = profile.monthlyBudget;
    final spentToday = _sumToday(expenses);
    final spentThisMonth = _sumThisMonth(expenses);
    final dailyProgress = dailyBudget > 0 ? (spentToday / dailyBudget).clamp(0.0, 1.0) : 0.0;
    final monthlyProgress = monthlyBudget > 0 ? (spentThisMonth / monthlyBudget).clamp(0.0, 1.0) : 0.0;

    final stackHeight = _frontHeight + (_backHeight - _backOverlap);

    // Whichever card is NOT front paints first (bottom of the Stack), and
    // front paints last (top) — keys preserve identity across reordering so
    // AnimatedPositioned interpolates smoothly instead of popping.
    final todayCard = AnimatedPositioned(
      key: const ValueKey('today'),
      duration: _duration,
      curve: _curve,
      top: _isTodayFront ? 0 : _frontHeight - _backOverlap,
      left: _isTodayFront ? 0 : 14,
      right: _isTodayFront ? 0 : 14,
      height: _isTodayFront ? _frontHeight : _backHeight,
      child: GestureDetector(
        onTap: _isTodayFront ? null : _flip,
        child: _FlipCard(
          colors: colors,
          label: 'TODAY',
          spent: spentToday,
          limit: dailyBudget,
          symbol: symbol,
          progress: dailyProgress,
          isFront: _isTodayFront,
        ),
      ),
    );

    final monthCard = AnimatedPositioned(
      key: const ValueKey('month'),
      duration: _duration,
      curve: _curve,
      top: !_isTodayFront ? 0 : _frontHeight - _backOverlap,
      left: !_isTodayFront ? 0 : 14,
      right: !_isTodayFront ? 0 : 14,
      height: !_isTodayFront ? _frontHeight : _backHeight,
      child: GestureDetector(
        onTap: !_isTodayFront ? null : _flip,
        child: _FlipCard(
          colors: colors,
          label: 'THIS MONTH',
          spent: spentThisMonth,
          limit: monthlyBudget,
          symbol: symbol,
          progress: monthlyProgress,
          isFront: !_isTodayFront,
        ),
      ),
    );

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        // Back card listed first (painted first = behind), front card last
        // (painted last = on top). Reordering on flip is fine here since
        // each AnimatedPositioned keeps its own ValueKey identity.
        children: _isTodayFront ? [monthCard, todayCard] : [todayCard, monthCard],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final AppColors colors;
  final String label;
  final double spent;
  final double limit;
  final String symbol;
  final double progress;
  final bool isFront;

  const _FlipCard({
    required this.colors,
    required this.label,
    required this.spent,
    required this.limit,
    required this.symbol,
    required this.progress,
    required this.isFront,
  });

  static const Duration _duration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    final remaining = limit - spent;
    final isOver = remaining < 0;
    final accentColor = isOver ? const Color.fromARGB(255, 243, 209, 213) : Colors.white;
    final radius = isFront ? 23.0 : 20.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: EdgeInsets.all(isFront ? 18 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFront
                ? [colors.primary, Color.lerp(colors.primary, Colors.black, 0.25)!]
                : [
                    Color.lerp(colors.primary, Colors.black, 0.45)!,
                    Color.lerp(colors.primary, Colors.black, 0.6)!,
                  ],
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isFront ? 0.35 : 0.3),
              blurRadius: isFront ? 30 : 20,
              offset: Offset(isFront ? 5 : 3, isFront ? 10 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTextStyles.small(Colors.white.withValues(alpha: 0.7)).copyWith(letterSpacing: 0.8),
                ),
                if (!isFront)
                  Flexible(
                    child: Text(
                      '$symbol${spent.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium(Colors.white).copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
            AnimatedDefaultTextStyle(
              duration: _duration,
              curve: Curves.easeOutCubic,
              style: isFront
                  ? AppTextStyles.heading2(Colors.white)
                  : AppTextStyles.heading2(Colors.white).copyWith(fontSize: 0, height: 0),
              child: isFront
                  ? Text(
                      '$symbol${spent.toStringAsFixed(2)}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : const SizedBox.shrink(),
            ),
            if (isFront) const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOver
                    ? (isFront
                        ? 'You\'ve spent $symbol${(-remaining).toStringAsFixed(0)} more than your limit !'
                        : '$symbol${(-remaining).toStringAsFixed(0)} over your limit')
                    : (isFront
                        ? 'You can spend $symbol${remaining.toStringAsFixed(0)}'
                        : '$symbol${remaining.toStringAsFixed(0)} left to spend'),
                style: AppTextStyles.caption(accentColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(height: isFront ? 8 : 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(isFront ? 8 : 6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: isFront ? 7 : 5,
                backgroundColor: Colors.white.withValues(alpha: isFront ? 0.25 : 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(isOver ? const Color(0xFFFFCDD2) : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}