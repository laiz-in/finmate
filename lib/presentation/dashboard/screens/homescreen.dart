import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_profile.dart';
import '../../profile/bloc/profile_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;

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
            const SizedBox(height: 20),
            _SafeToSpendCard(colors: colors, profile: profile),
            const SizedBox(height: 28),
            _BudgetsSection(colors: colors, profile: profile),
            const SizedBox(height: 24),
            _CircleCard(colors: colors),
            const SizedBox(height: 16),
            _SavingsGoalsRow(colors: colors, profile: profile),
          ],
        ),
      ),
    );
  }
}

// ---------------- Date helper ----------------

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _formattedToday() {
  final now = DateTime.now();
  final weekday = _weekdays[now.weekday - 1].toUpperCase();
  final month = _months[now.month - 1].toUpperCase();
  return '$weekday, ${now.day} $month';
}

int _daysInCurrentMonth() {
  final now = DateTime.now();
  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final lastDay = nextMonth.subtract(const Duration(days: 1));
  return lastDay.day;
}

// ---------------- Header ----------------

class _Header extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _Header({required this.colors, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formattedToday(),
              style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            Text('Morning, ${profile.firstName}', style: AppTextStyles.heading1(colors.textPrimary)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text('34d streak', style: AppTextStyles.caption(colors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Safe to spend card ----------------

class _SafeToSpendCard extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _SafeToSpendCard({required this.colors, required this.profile});

  @override
  Widget build(BuildContext context) {
    final symbol = profile.currencySymbol;
    final dailyBudget = profile.dailyBudget;
    final monthlyBudget = profile.monthlyBudget;

    // Placeholder until real expense tracking exists — assumes nothing spent yet today.
    final safeToday = dailyBudget;
    const double spentThisMonth = 0;
    final progress = monthlyBudget > 0 ? (spentThisMonth / monthlyBudget).clamp(0.0, 1.0) : 0.0;

    final now = DateTime.now();
    final totalDays = _daysInCurrentMonth();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SAFE TO SPEND TODAY', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$symbol${safeToday.toStringAsFixed(2)}', style: AppTextStyles.display(colors.textPrimary)),
              const SizedBox(width: 8),
              Text('of $symbol${dailyBudget.toStringAsFixed(0)} planned', style: AppTextStyles.body(colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$symbol${spentThisMonth.toStringAsFixed(2)} spent this month',
                style: AppTextStyles.caption(colors.textSecondary),
              ),
              Text('day ${now.day} / $totalDays', style: AppTextStyles.caption(colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Budgets section ----------------

class _BudgetsSection extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _BudgetsSection({required this.colors, required this.profile});

  static const List<Color> _palette = [
    Color(0xFFE07A5F),
    Color(0xFF4A90D9),
    Color(0xFF9B7EDE),
    Color(0xFFE0B84A),
    Color(0xFF5FBF8F),
    Color(0xFFD97BB0),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = profile.spendingCategories;
    // Naive even split of the monthly budget across categories until per-category
    // budgets and real expense tracking exist.
    final perCategoryLimit = categories.isNotEmpty ? profile.monthlyBudget / categories.length : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budgets', style: AppTextStyles.heading3(colors.textPrimary)),
            Text('All money', style: AppTextStyles.bodyMedium(colors.primary)),
          ],
        ),
        const SizedBox(height: 14),
        if (categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Text('No categories set up yet', style: AppTextStyles.body(colors.textSecondary)),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: List.generate(categories.length, (i) {
                return _BudgetTile(
                  colors: colors,
                  name: categories[i],
                  spent: 0, // placeholder until real expense data exists
                  limit: perCategoryLimit,
                  symbol: profile.currencySymbol,
                  color: _palette[i % _palette.length],
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final AppColors colors;
  final String name;
  final double spent;
  final double limit;
  final String symbol;
  final Color color;

  const _BudgetTile({
    required this.colors,
    required this.name,
    required this.spent,
    required this.limit,
    required this.symbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium(colors.textPrimary)),
                    Text(
                      '$symbol${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                      style: AppTextStyles.caption(colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Circle card (still dummy — group feature not built yet) ----------------

class _CircleCard extends StatelessWidget {
  final AppColors colors;
  const _CircleCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    final members = ['M', 'J', 'A', 'T', 'S'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR CIRCLE · 6 MEMBERS',
                style: AppTextStyles.small(Colors.white.withOpacity(0.8)).copyWith(letterSpacing: 0.8),
              ),
              Text('day 12 / 21', style: AppTextStyles.small(Colors.white.withOpacity(0.8))),
            ],
          ),
          const SizedBox(height: 10),
          Text('Autumn No-Spend Sprint', style: AppTextStyles.heading3(Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: members.length * 24.0 + 12,
                height: 32,
                child: Stack(
                  children: List.generate(members.length, (i) {
                    return Positioned(
                      left: i * 24.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Text(
                          members[i],
                          style: AppTextStyles.caption(colors.primary).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You're 2nd — \$218 saved vs your usual",
                  style: AppTextStyles.caption(Colors.white.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Savings goals row (still dummy — savings goals feature not built yet) ----------------

class _SavingsGoalsRow extends StatelessWidget {
  final AppColors colors;
  final UserProfile profile;
  const _SavingsGoalsRow({required this.colors, required this.profile});

  @override
  Widget build(BuildContext context) {
    final symbol = profile.currencySymbol;
    return Row(
      children: [
        Expanded(child: _GoalCard(colors: colors, title: 'Iceland, March', amount: '$symbol 4,840')),
        const SizedBox(width: 12),
        Expanded(child: _GoalCard(colors: colors, title: 'Emergency fund', amount: '$symbol 4,200')),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final String amount;
  const _GoalCard({required this.colors, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption(colors.textSecondary)),
          const SizedBox(height: 6),
          Text(amount, style: AppTextStyles.heading3(colors.textPrimary)),
        ],
      ),
    );
  }
}