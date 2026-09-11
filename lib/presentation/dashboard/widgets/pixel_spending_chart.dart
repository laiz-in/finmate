import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';

class PixelSpendingChart extends StatelessWidget {
  final AppColors colors;
  final List<Expense> expenses;
  final String symbol;
  final int daysToShow;

  const PixelSpendingChart({
    super.key,
    required this.colors,
    required this.expenses,
    required this.symbol,
    this.daysToShow = 15,
  });

  List<_DayTotal> _recentDays() {
    final today = DateTime.now();
    return List.generate(daysToShow, (i) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: daysToShow - 1 - i));
      final total = expenses
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .fold(0.0, (sum, e) => sum + e.amount);
      return _DayTotal(date: date, total: total);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _recentDays();
    final maxValue = days.map((d) => d.total).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAST $daysToShow DAYS', style: AppTextStyles.small(colors.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _PixelChartPainter(
                days: days,
                maxValue: maxValue,
                primary: colors.primary,
                textColor: colors.textPrimary,
                fadedTextColor: colors.textSecondary,
                surfaceColor: colors.surface,
                symbol: symbol,
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

class _PixelChartPainter extends CustomPainter {
  final List<_DayTotal> days;
  final double maxValue;
  final Color primary;
  final Color textColor;
  final Color fadedTextColor;
  final Color surfaceColor;
  final String symbol;

  static const int rows = 14;
  static const double gap = 3;
  static const double labelSpace = 30;
  static const double bottomLabelSpace = 20;

  _PixelChartPainter({
    required this.days,
    required this.maxValue,
    required this.primary,
    required this.textColor,
    required this.fadedTextColor,
    required this.surfaceColor,
    required this.symbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final columns = days.length;
    if (columns == 0) return;

    final gridBottom = size.height - bottomLabelSpace;
    final gridTop = labelSpace;
    final gridHeight = gridBottom - gridTop;

    final cellWidth = (size.width - gap * (columns - 1)) / columns;
    final cellHeight = (gridHeight - gap * (rows - 1)) / rows;

    int peakIndex = 0;
    for (int i = 1; i < days.length; i++) {
      if (days[i].total > days[peakIndex].total) peakIndex = i;
    }

    for (int col = 0; col < columns; col++) {
      final value = days[col].total;
      final filledRows = maxValue > 0
          ? (value / maxValue * rows).round().clamp(0, rows)
          : 0;

      final colLeft = col * (cellWidth + gap);

      for (int row = 0; row < rows; row++) {
        final rowTop = gridBottom - (row + 1) * cellHeight - row * gap;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(colLeft, rowTop, cellWidth, cellHeight),
          const Radius.circular(1),
        );

        final paint = Paint();
        final isPeakTopCell = col == peakIndex && row == filledRows - 1 && filledRows > 0;

        if (row < filledRows) {
          // Filled cell — gradient from solid primary at the base to a
          // lighter tint near the top of the bar.
          final t = filledRows <= 1 ? 0.0 : row / (filledRows - 1);
          paint.color = Color.lerp(primary, Colors.white, t * 0.35)!
              .withValues(alpha: isPeakTopCell ? 1.0 : 0.95);
        } else {
          // Empty cell — same green, very low opacity, so the grid still
          // reads as "your color" rather than neutral grey.
          paint.color = primary.withValues(alpha: 0.06);
        }

        canvas.drawRRect(rect, paint);

        if (isPeakTopCell) {
          final borderPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4;
          canvas.drawRRect(rect, borderPaint);
        }
      }

      // Bottom-axis day number.
      final dayText = TextPainter(
        text: TextSpan(
          text: '${days[col].date.day}',
          style: AppTextStyles.small(fadedTextColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayText.paint(
        canvas,
        Offset(colLeft + (cellWidth - dayText.width) / 2, gridBottom + 6),
      );
    }

    // Peak callout label, positioned above the tallest column.
    if (maxValue > 0) {
      final peakFilledRows = (maxValue / maxValue * rows).round().clamp(0, rows);
      final peakColLeft = peakIndex * (cellWidth + gap);
      final peakTop = gridBottom - peakFilledRows * cellHeight - (peakFilledRows - 1) * gap;

      final labelText = TextPainter(
        text: TextSpan(
          text: '$symbol${maxValue.toStringAsFixed(0)}',
          style: AppTextStyles.small(textColor).copyWith(fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double labelX = peakColLeft + cellWidth / 2 - labelText.width / 2;
      labelX = labelX.clamp(0.0, size.width - labelText.width);
      final labelY = (peakTop - labelText.height - 6).clamp(0.0, size.height);

      labelText.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _PixelChartPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.primary != primary;
  }
}