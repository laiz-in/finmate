import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';

const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

class SpendingChart extends StatelessWidget {
  final AppColors colors;
  final List<Expense> expenses;
  final String symbol;

  const SpendingChart({
    super.key,
    required this.colors,
    required this.expenses,
    required this.symbol,
  });

  /// Returns 15 entries, oldest first, today last — one total per day.
  List<_DayTotal> _last15Days() {
    final today = DateTime.now();
    final days = List.generate(15, (i) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 14 - i));
      final total = expenses
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .fold(0.0, (sum, e) => sum + e.amount);
      return _DayTotal(date: date, total: total);
    });
    return days;
  }

  String _fullDate(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final days = _last15Days();
    final maxValue = days.map((d) => d.total).fold(0.0, (a, b) => a > b ? a : b);
    final maxDay = days.firstWhere(
      (d) => d.total == maxValue,
      orElse: () => days.last,
    );
    // Headroom above the tallest bar so it doesn't touch the top edge;
    // falls back to 100 when there's no spending yet, so the chart isn't flat.
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 15 days', style: AppTextStyles.heading3(colors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            maxValue > 0
                ? 'You spent $symbol${maxValue.toStringAsFixed(0)} on ${_fullDate(maxDay.date)} !'
                : 'No spending yet in this period',
            style: AppTextStyles.caption(colors.textSecondary),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.textPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = days[group.x.toInt()];
                      return BarTooltipItem(
                        '$symbol${day.total.toStringAsFixed(0)}\n',
                        AppTextStyles.caption(colors.background).copyWith(fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: _fullDate(day.date),
                            style: AppTextStyles.small(colors.background.withValues(alpha: 0.8)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${days[index].date.day}',
                            style: AppTextStyles.small(colors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(days.length, (i) {
                  final isToday = i == days.length - 1;
                  final isMax = maxValue > 0 && days[i].total == maxValue;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: days[i].total,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        color: isMax
                            ? colors.primary
                            : (isToday
                                ? colors.primary.withValues(alpha: 0.9)
                                : colors.primary.withValues(alpha: 0.35)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTotal {
  final DateTime date;
  final double total;
  const _DayTotal({required this.date, required this.total});
}